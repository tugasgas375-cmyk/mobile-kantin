import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final store = Store.instance;
  final cart = <CartItem>[];
  final customerCtrl = TextEditingController();

  void _add(Product product) {
    setState(() {
      final existing = cart.where((item) => item.product.id == product.id).firstOrNull;
      if (existing != null) {
        existing.qty++;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  void _remove(CartItem item) {
    setState(() {
      if (item.qty > 1) {
        item.qty--;
      } else {
        cart.remove(item);
      }
    });
  }

  int get total => cart.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> _checkout() async {
    if (cart.isEmpty) return;
    final customer = customerCtrl.text.trim().isEmpty ? 'Umum' : customerCtrl.text.trim();
    final transaction = Transaction(
      id: store.createTransactionId(),
      customer: customer,
      items: cart.map((item) => CartItem(product: item.product, qty: item.qty)).toList(),
      total: total,
      time: DateTime.now(),
    );

    store.transactions.add(transaction);
    await store.persist();
    if (!mounted) return;

    setState(() {
      cart.clear();
      customerCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaksi ${transaction.id} berhasil • Total ${store.formatRupiah(transaction.total)}')),
    );
  }

  Future<void> _advanceOrder(Order order) async {
    final nextStatus = switch (order.status) {
      OrderStatus.pending => OrderStatus.processing,
      OrderStatus.processing => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.completed,
      OrderStatus.completed => OrderStatus.completed,
    };

    await store.updateOrderStatus(order.id, nextStatus);
  }

  @override
  void dispose() {
    customerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Pilih Produk', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (store.products.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Belum ada produk')))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: store.products
                        .map((product) => ActionChip(
                              avatar: const Icon(Icons.add, size: 16),
                              label: Text('${product.name}\n${store.formatRupiah(product.price)}'),
                              onPressed: () => _add(product),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),
                Text('Pesanan pelanggan', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                StreamBuilder<List<Order>>(
                  stream: store.watchOrders(),
                  builder: (context, snapshot) {
                    final orders = snapshot.data ?? const [];
                    if (orders.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Belum ada pesanan masuk.'),
                        ),
                      );
                    }

                    return Column(
                      children: orders.map((order) {
                        final canAdvance = order.status != OrderStatus.completed;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(orderStatusLabel(order.status)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(order.items.map((item) => '${item.product.name} x${item.qty}').join(', ')),
                                const SizedBox(height: 6),
                                Text('Total: ${store.formatRupiah(order.total)}'),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.tonal(
                                    onPressed: canAdvance ? () => _advanceOrder(order) : null,
                                    child: Text(canAdvance ? 'Ubah status' : 'Selesai'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: customerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama customer',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Keranjang kosong'))
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: cart
                              .map((item) => ListTile(
                                    dense: true,
                                    title: Text(item.product.name),
                                    subtitle: Text(
                                        '${item.qty} x ${store.formatRupiah(item.product.price)} = ${store.formatRupiah(item.subtotal)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _remove(item)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () => setState(() => item.qty++),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Total: ${store.formatRupiah(total)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        FilledButton.icon(
                          onPressed: cart.isEmpty ? null : _checkout,
                          icon: const Icon(Icons.payment),
                          label: const Text('Bayar'),
                        ),
                      ],
                    ),
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
