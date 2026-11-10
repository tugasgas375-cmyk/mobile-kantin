import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final store = Store.instance;
  final searchCtrl = TextEditingController();
  final customerNameCtrl = TextEditingController(text: 'Pelanggan');
  final cart = <CartItem>[];
  String query = '';
  String selectedCategory = 'Semua';

  List<String> get categories => ['Semua', ...{for (final product in store.products) product.category}];
  List<Product> get filteredProducts => store.products.where((product) {
        final matchesName = product.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = selectedCategory == 'Semua' || product.category == selectedCategory;
        return matchesName && matchesCategory;
      }).toList();
  int get total => cart.fold(0, (sum, item) => sum + item.subtotal);
  int get cartCount => cart.fold(0, (sum, item) => sum + item.qty);

  void _add(Product product) {
    setState(() {
      final existing = cart.firstWhereOrNull((item) => item.product.id == product.id);
      if (existing == null) {
        cart.add(CartItem(product: product));
      } else {
        existing.qty++;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} ditambahkan ke keranjang'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 900),
    ));
  }

  void _changeQuantity(CartItem item, int change, void Function(void Function()) updateSheet) {
    setState(() {
      item.qty += change;
      if (item.qty <= 0) cart.remove(item);
    });
    updateSheet(() {});
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) return;
    try {
      await store.submitCustomerOrder(customerNameCtrl.text.trim(), cart.toList());
      if (!mounted) return;
      setState(() {
        cart.clear();
        customerNameCtrl.text = 'Pelanggan';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dikirim ke kasir.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pesanan gagal dikirim: $error')));
    }
  }

  Future<void> _showCart() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, updateSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .72),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Keranjang', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('$cartCount item dipilih', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                TextField(controller: customerNameCtrl, decoration: const InputDecoration(labelText: 'Nama pelanggan', prefixIcon: Icon(Icons.person_outline_rounded))),
                const SizedBox(height: 12),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Keranjang masih kosong'))
                      : ListView.separated(
                          itemCount: cart.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(store.formatRupiah(item.subtotal)),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(onPressed: () => _changeQuantity(item, -1, updateSheet), icon: const Icon(Icons.remove_circle_outline_rounded)),
                                Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                IconButton(onPressed: () => _changeQuantity(item, 1, updateSheet), icon: const Icon(Icons.add_circle_outline_rounded)),
                              ]),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total pembayaran', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)), Text(store.formatRupiah(total), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))])),
                  FilledButton.icon(
                    onPressed: cart.isEmpty ? null : () async {
                      Navigator.pop(sheetContext);
                      await _checkout();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Pesan'),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    customerNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('KANTIN POS', style: TextStyle(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: Color(0xFFB84A24))),
          Text('Jelajahi menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(onPressed: _showCart, tooltip: 'Keranjang', icon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), child: const Icon(Icons.shopping_bag_outlined))),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [scheme.primary, const Color(0xFFE58A4F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(20)), child: const Text('SEGAR & LEZAT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1))),
              const SizedBox(height: 13),
              const Text('Makan enak,\ntanpa antre.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.4)),
              const SizedBox(height: 7),
              const Text('Pilih menu favoritmu hari ini.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            const SizedBox(width: 8),
            const Icon(Icons.ramen_dining_rounded, size: 82, color: Colors.white70),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: searchCtrl,
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: InputDecoration(hintText: 'Cari makanan atau minuman', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: query.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () { searchCtrl.clear(); setState(() => query = ''); })),
          ),
        ),
        SizedBox(height: 56, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), children: categories.map((category) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(category), selected: category == selectedCategory, onSelected: (_) => setState(() => selectedCategory = category))).toList())),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
          child: Row(children: [Expanded(child: Text('Menu pilihan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), Text('${filteredProducts.length} menu', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search_off_rounded, size: 42, color: Colors.grey.shade400), const SizedBox(height: 8), const Text('Menu tidak ditemukan')]))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, mainAxisExtent: 220, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isDrink = product.category == 'Minuman';
                    final accent = isDrink ? const Color(0xFF5977A8) : scheme.primary;
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _add(product),
                        child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(16)), child: Center(child: Icon(isDrink ? Icons.local_cafe_rounded : Icons.lunch_dining_rounded, size: 45, color: accent)))),
                          const SizedBox(height: 12),
                          Text(product.category.toUpperCase(), style: TextStyle(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: accent)),
                          const SizedBox(height: 4),
                          Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 7),
                          Row(children: [Expanded(child: Text(store.formatRupiah(product.price), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800))), Icon(Icons.add_circle_rounded, color: scheme.primary, size: 26)]),
                        ])),
                      ),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: cart.isEmpty ? null : FloatingActionButton.extended(onPressed: _showCart, icon: const Icon(Icons.shopping_bag_rounded), label: Text('$cartCount item  ·  ${store.formatRupiah(total)}')),
    );
  }
}

extension IterableFirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
