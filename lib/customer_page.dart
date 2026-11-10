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
  final cart = <CartItem>[];
  String query = '';

  List<Product> get filteredProducts => store.products
      .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

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
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: const Duration(milliseconds: 900),
      ),
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi pesanan'),
        content: Text('Pesanan Anda berjumlah ${store.formatRupiah(total)}. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Kembali')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Pesan sekarang')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final transaction = Transaction(
      id: store.createTransactionId(),
      customer: 'Pelanggan',
      items: cart.map((item) => CartItem(product: item.product, qty: item.qty)).toList(),
      total: total,
      time: DateTime.now(),
    );

    store.transactions.add(transaction);
    await store.persist();
    if (!mounted) return;

    setState(cart.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pesanan ${transaction.id} berhasil dibuat')),
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
                if (cart.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Keranjang masih kosong')),
                  )
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _changeQuantity(item, -1);
                                  updateSheet(() {});
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.qty}'),
                              IconButton(
                                onPressed: () {
                                  _changeQuantity(item, 1);
                                  updateSheet(() {});
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Total  ${store.formatRupiah(total)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    FilledButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _checkout();
                            },
                      child: const Text('Buat pesanan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Kantin'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: _showCart,
            icon: Badge(label: Text('${cart.fold<int>(0, (sum, item) => sum + item.qty)}'), child: const Icon(Icons.shopping_bag_outlined)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.restaurant, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text('Makan enak,\ngak perlu antre.',
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Pilih menu favoritmu dan pesan langsung.', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchCtrl,
              onChanged: (value) => setState(() => query = value.trim()),
              decoration: InputDecoration(
                hintText: 'Cari makanan atau minuman',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text('Menu favorit', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                Text('${filteredProducts.length} menu', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('Menu tidak ditemukan'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 190,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    child: Icon(Icons.fastfood, size: 32, color: theme.colorScheme.primary),
                                  ),
                                ),
                              ),
                              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(store.formatRupiah(product.price),
                                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton.filledTonal(
                                    onPressed: () => _add(product),
                                    tooltip: 'Tambah ke keranjang',
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCart,
              icon: const Icon(Icons.shopping_bag),
              label: Text('Keranjang • ${store.formatRupiah(total)}'),
            ),
    );
  }
}
