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

  void _add(Product product) {
    setState(() {
      final existing = cart.where((item) => item.product.id == product.id).firstOrNull;
      if (existing == null) {
        cart.add(CartItem(product: product));
      } else {
        existing.qty++;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ditambahkan ke keranjang'), duration: const Duration(milliseconds: 900)),
    );
  }

  void _changeQuantity(CartItem item, int change) {
    setState(() {
      item.qty += change;
      if (item.qty <= 0) cart.remove(item);
    });
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) return;

    final customerName = customerNameCtrl.text.trim();
    await store.submitCustomerOrder(customerName, cart.toList());

    if (!mounted) return;

    setState(() {
      cart.clear();
      customerNameCtrl.text = 'Pelanggan';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan dikirim ke kasir.')),
    );
  }

  void _showCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, updateSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keranjang kamu', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: customerNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama pelanggan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (cart.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('Keranjang masih kosong')))
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cart.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.product.name),
                          subtitle: Text(store.formatRupiah(item.subtotal)),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(onPressed: () { _changeQuantity(item, -1); updateSheet(() {}); }, icon: const Icon(Icons.remove_circle_outline)),
                            Text('${item.qty}'),
                            IconButton(onPressed: () { _changeQuantity(item, 1); updateSheet(() {}); }, icon: const Icon(Icons.add_circle_outline)),
                          ]),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Text('Total  ${store.formatRupiah(total)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                  FilledButton(
                    onPressed: cart.isEmpty ? null : () async { Navigator.pop(context); await _checkout(); },
                    child: const Text('Buat pesanan'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() { if (mounted) setState(() {}); });
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
    final cartCount = cart.fold<int>(0, (sum, item) => sum + item.qty);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Kantin'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: _showCart,
            icon: Badge(label: Text('$cartCount'), child: const Icon(Icons.shopping_bag_outlined)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.restaurant, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text('Makan enak,\ngak perlu antre.', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Pilih menu favoritmu dan pesan langsung.', style: TextStyle(color: Colors.white)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: searchCtrl,
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Cari makanan atau minuman', prefixIcon: const Icon(Icons.search), filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            scrollDirection: Axis.horizontal,
            children: categories.map((category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: category == selectedCategory,
                onSelected: (_) => setState(() => selectedCategory = category),
              ),
            )).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Expanded(child: Text('Menu favorit', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
            Text('${filteredProducts.length} menu', style: theme.textTheme.bodySmall),
          ]),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text('Menu tidak ditemukan'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240, mainAxisExtent: 200, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Center(child: CircleAvatar(
                            radius: 32,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(product.category == 'Minuman' ? Icons.local_cafe : Icons.fastfood, size: 32, color: theme.colorScheme.primary),
                          ))),
                          Text(product.category, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary)),
                          const SizedBox(height: 3),
                          Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(children: [
                            Expanded(child: Text(store.formatRupiah(product.price), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                            IconButton.filledTonal(onPressed: () => _add(product), tooltip: 'Tambah ke keranjang', icon: const Icon(Icons.add)),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: cart.isEmpty ? null : FloatingActionButton.extended(
        onPressed: _showCart, icon: const Icon(Icons.shopping_bag), label: Text('Keranjang • ${store.formatRupiah(total)}'),
      ),
    );
  }
}
