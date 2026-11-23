import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final Store store = Store.instance;
  final cart = <CartItem>[];
  final customerController = TextEditingController();

  int get total => cart.fold(0, (sum, item) => sum + item.subtotal);

  void addProduct(Product product) {
    setState(() {
      final existing = cart.where((item) => item.product.id == product.id).firstOrNull;
      if (existing == null) {
        cart.add(CartItem(product: product));
      } else {
        existing.qty++;
      }
    });
  }

  void removeProduct(CartItem item) {
    setState(() {
      if (item.qty > 1) {
        item.qty--;
      } else {
        cart.remove(item);
      }
    });
  }

  Future<void> checkout() async {
    if (cart.isEmpty) return;

    final transaction = Transaction(
      id: store.createTransactionId(),
      customer: customerController.text.trim().isEmpty
          ? 'Umum'
          : customerController.text.trim(),
      items: cart.map((item) => CartItem(product: item.product, qty: item.qty)).toList(),
      total: total,
      time: DateTime.now(),
    );

    store.transactions.add(transaction);
    await store.persist();
    if (!mounted) return;

    setState(() {
      cart.clear();
      customerController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaksi berhasil • ${store.formatRupiah(transaction.total)}')),
    );
  }

  @override
  void dispose() {
    customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir')),
      body: Column(
        children: [
          Expanded(
            child: store.products.isEmpty
                ? const Center(child: Text('Belum ada produk'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Pilih Produk', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: store.products.map((product) {
                          return ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: Text('${product.name}\n${store.formatRupiah(product.price)}'),
                            onPressed: () => addProduct(product),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text('Pesanan pelanggan', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      StreamBuilder<List<Order>>(
                        stream: store.watchOrders(),
                        builder: (context, snapshot) {
                          final orders = snapshot.data ?? const [];
                          if (orders.isEmpty) {
                            return const Card(child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Belum ada pesanan masuk'),
                            ));
                          }
                          return Column(children: orders.map((order) {
                            return Card(
                              child: ListTile(
                                title: Text(order.customerName),
                                subtitle: Text(orderStatusLabel(order.status)),
                                trailing: Text(store.formatRupiah(order.total)),
                              ),
                            );
                          }).toList());
                        },
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 220,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: customerController,
                    decoration: const InputDecoration(
                      labelText: 'Nama customer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Keranjang kosong'))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: cart.map((item) {
                            return ListTile(
                              title: Text(item.product.name),
                              subtitle: Text('${item.qty} × ${store.formatRupiah(item.product.price)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => removeProduct(item),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => item.qty++),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Total: ${store.formatRupiah(total)}'),
                      ),
                      FilledButton(
                        onPressed: cart.isEmpty ? null : checkout,
                        child: const Text('Bayar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
