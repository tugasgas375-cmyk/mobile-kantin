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

  void _add(Product p) {
    setState(() {
      final existing = cart.where((c) => c.product.id == p.id).firstOrNull;
      if (existing != null) {
        existing.qty++;
      } else {
        cart.add(CartItem(product: p));
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

  int get total => cart.fold(0, (sum, c) => sum + c.subtotal);

  void _checkout() {
    if (cart.isEmpty) return;
    final customer = customerCtrl.text.trim().isEmpty ? 'Umum' : customerCtrl.text.trim();

    final trx = Transaction(
      id: 'TRX-${(store.transactions.length + 1).toString().padLeft(3, '0')}',
      customer: customer,
      items: List.from(cart),
      total: total,
      time: DateTime.now(),
    );

    setState(() {
      store.transactions.add(trx);
      store.persist();
      cart.clear();
      customerCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaksi ${trx.id} berhasil • Total ${store.formatRupiah(trx.total)}')),
    );
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
              padding: const EdgeInsets.all(12),
              children: [
                const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: store.products
                      .map((p) => ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: Text('${p.name}\n${store.formatRupiah(p.price)}'),
                            onPressed: () => _add(p),
                          ))
                      .toList(),
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
                              .map((c) => ListTile(
                                    dense: true,
                                    title: Text(c.product.name),
                                    subtitle: Text(
                                        '${c.qty} x ${store.formatRupiah(c.product.price)} = ${store.formatRupiah(c.subtotal)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () => _remove(c),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () => setState(() => c.qty++),
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
