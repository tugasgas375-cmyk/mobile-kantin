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
  static const _categories = ['Makanan', 'Minuman', 'Camilan', 'Lainnya'];

  Future<void> _addProduct() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    var category = _categories.first;

    final product = await showDialog<Product>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, updateDialog) => AlertDialog(
          title: const Text('Tambah Produk'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: nameCtrl, autofocus: true, maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Nama produk', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Nama produk wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                  items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                  onChanged: (value) { if (value != null) updateDialog(() => category = value); },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder()),
                  validator: (value) {
                    final price = int.tryParse(value?.trim() ?? '');
                    return price == null || price <= 0 ? 'Masukkan harga lebih dari Rp 0' : null;
                  },
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx, Product(
                  id: store.createProductId(), name: nameCtrl.text.trim(),
                  price: int.parse(priceCtrl.text.trim()), category: category,
                ));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
    if (product == null || !mounted) return;
    setState(() => store.products.add(product));
    await store.persist();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('Produk "${product.name}" akan dihapus dari menu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => store.products.removeWhere((item) => item.id == product.id));
    await store.persist();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Kantin'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Produk'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transaksi'),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(onPressed: _addProduct, icon: const Icon(Icons.add), label: const Text('Produk')),
        body: TabBarView(children: [
          store.products.isEmpty
              ? const Center(child: Text('Belum ada produk. Tambahkan produk pertama.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16), itemCount: store.products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = store.products[index];
                    return Card(child: ListTile(
                      leading: CircleAvatar(child: Icon(product.category == 'Minuman' ? Icons.local_cafe : Icons.fastfood)),
                      title: Text(product.name),
                      subtitle: Text('${product.category} • ${store.formatRupiah(product.price)}'),
                      trailing: IconButton(tooltip: 'Hapus ${product.name}', icon: Icon(Icons.delete_outline, color: theme.colorScheme.error), onPressed: () => _deleteProduct(product)),
                    ));
                  },
                ),
          store.transactions.isEmpty
              ? const Center(child: Text('Belum ada transaksi'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16), itemCount: store.transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = store.transactions[store.transactions.length - 1 - index];
                    return Card(child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                      title: Text('${transaction.id} • ${transaction.customer}'),
                      subtitle: Text('${transaction.items.map((item) => '${item.product.name} x${item.qty}').join(', ')}\n'
                          '${transaction.time.day}/${transaction.time.month}/${transaction.time.year} ${transaction.time.hour.toString().padLeft(2, '0')}:${transaction.time.minute.toString().padLeft(2, '0')}'),
                      isThreeLine: true,
                      trailing: Text(store.formatRupiah(transaction.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ));
                  },
                ),
        ]),
      ),
    );
  }
}
