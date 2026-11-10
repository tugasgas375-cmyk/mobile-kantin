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
      builder: (ctx) => StatefulBuilder(builder: (ctx, updateDialog) => AlertDialog(
        title: const Text('Tambah produk'),
        content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: nameCtrl, autofocus: true, maxLength: 50, decoration: const InputDecoration(labelText: 'Nama produk', prefixIcon: Icon(Icons.restaurant_menu_rounded)), validator: (value) => value == null || value.trim().isEmpty ? 'Nama produk wajib diisi' : null),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category_outlined)), items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) { if (value != null) updateDialog(() => category = value); }),
          const SizedBox(height: 12),
          TextFormField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)', prefixIcon: Icon(Icons.payments_outlined)), validator: (value) { final price = int.tryParse(value?.trim() ?? ''); return price == null || price <= 0 ? 'Masukkan harga lebih dari Rp 0' : null; }),
        ]))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')), FilledButton(onPressed: () {
          if (!formKey.currentState!.validate()) return;
          Navigator.pop(ctx, Product(id: store.createProductId(), name: nameCtrl.text.trim(), price: int.parse(priceCtrl.text.trim()), category: category));
        }, child: const Text('Simpan produk'))],
      )),
    );
    nameCtrl.dispose();
    priceCtrl.dispose();
    if (product == null || !mounted) return;
    setState(() => store.products.add(product));
    await store.persist();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline_rounded),
      title: const Text('Hapus produk?'),
      content: Text('"${product.name}" akan dihapus dari menu kantin.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => store.products.removeWhere((item) => item.id == product.id));
    await store.persist();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('KANTIN POS', style: TextStyle(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: Color(0xFFB84A24)),), Text('Manajemen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))]), bottom: const TabBar(tabs: [Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Produk'), Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Transaksi')])),
        floatingActionButton: FloatingActionButton.extended(onPressed: _addProduct, icon: const Icon(Icons.add_rounded), label: const Text('Tambah produk')),
        body: TabBarView(children: [
          store.products.isEmpty
              ? const _AdminEmpty(icon: Icons.inventory_2_outlined, title: 'Belum ada produk', subtitle: 'Tambahkan produk untuk mulai menyusun menu.')
              : ListView(padding: const EdgeInsets.all(16), children: [
                  _summaryBanner(context, 'Menu kantin', '${store.products.length} produk tersedia', Icons.storefront_rounded),
                  const SizedBox(height: 14),
                  ...store.products.map((product) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(product.category == 'Minuman' ? Icons.local_cafe_rounded : Icons.lunch_dining_rounded, color: scheme.primary)),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${product.category}  ·  ${store.formatRupiah(product.price)}'),
                    trailing: IconButton(tooltip: 'Hapus ${product.name}', icon: Icon(Icons.delete_outline_rounded, color: scheme.error), onPressed: () => _deleteProduct(product)),
                  )))),
                ]),
          store.transactions.isEmpty
              ? const _AdminEmpty(icon: Icons.receipt_long_outlined, title: 'Belum ada transaksi', subtitle: 'Transaksi penjualan akan tampil di sini.')
              : ListView(padding: const EdgeInsets.all(16), children: [
                  _summaryBanner(context, 'Riwayat transaksi', '${store.transactions.length} transaksi tercatat', Icons.insights_rounded),
                  const SizedBox(height: 14),
                  ...List.generate(store.transactions.length, (index) {
                    final transaction = store.transactions[store.transactions.length - 1 - index];
                    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF5977A8).withValues(alpha: .1), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF5977A8))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(transaction.customer, style: const TextStyle(fontWeight: FontWeight.w800)), Text(transaction.id, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))])), Text(store.formatRupiah(transaction.total), style: const TextStyle(fontWeight: FontWeight.w800))]),
                      const SizedBox(height: 12),
                      Text(transaction.items.map((item) => '${item.product.name} × ${item.qty}').join('  ·  '), style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      const SizedBox(height: 7),
                      Text('${transaction.time.day}/${transaction.time.month}/${transaction.time.year}  ·  ${transaction.time.hour.toString().padLeft(2, '0')}:${transaction.time.minute.toString().padLeft(2, '0')}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ]))));
                  }),
                ]),
        ]),
      ),
    );
  }

  Widget _summaryBanner(BuildContext context, String title, String subtitle, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: LinearGradient(colors: [scheme.primary, const Color(0xFFE58A4F)]), borderRadius: BorderRadius.circular(22)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.white)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))]))]));
  }
}

class _AdminEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _AdminEmpty({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48, color: Colors.grey.shade400), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), const SizedBox(height: 5), Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600))])));
}
