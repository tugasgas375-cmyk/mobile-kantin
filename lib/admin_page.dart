import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final store = Store.instance;

  void _addProduct() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama produk', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
              if (name.isNotEmpty && price > 0) {
                setState(() {
                  store.products.add(
                    Product(
                      id: 'P${(store.products.length + 1).toString().padLeft(2, '0')}',
                      name: name,
                      price: price,
                    ),
                  );
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    setState(() => store.products.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: const TabBar(tabs: [Tab(text: 'Produk'), Tab(text: 'Transaksi')]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addProduct,
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: store.products.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final p = store.products[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(store.formatRupiah(p.price)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteProduct(i),
                  ),
                );
              },
            ),
            store.transactions.isEmpty
                ? const Center(child: Text('Belum ada transaksi'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: store.transactions.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final t = store.transactions[i];
                      return Card(
                        child: ListTile(
                          title: Text('${t.id} • ${t.customer}'),
                          subtitle: Text(
                            '${t.items.map((e) => '${e.product.name} x${e.qty}').join(', ')}\n'
                            '${t.time.day}/${t.time.month}/${t.time.year} ${t.time.hour}:${t.time.minute.toString().padLeft(2, '0')}',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            store.formatRupiah(t.total),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
