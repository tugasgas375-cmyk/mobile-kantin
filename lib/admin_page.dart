import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final Store store = Store.instance;
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String category = 'Makanan';

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text.trim());
    if (name.isEmpty || price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga produk tidak valid')),
      );
      return;
    }

    setState(() {
      store.products.add(Product(
        id: store.createProductId(),
        name: name,
        price: price,
        category: category,
      ));
    });
    await store.persist();
    nameController.clear();
    priceController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tambah Produk', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama produk',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: const ['Makanan', 'Minuman', 'Camilan', 'Lainnya']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => category = value);
            },
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _addProduct,
            child: const Text('Simpan Produk'),
          ),
          const SizedBox(height: 24),
          Text('Daftar Produk', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (store.products.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada produk'),
            ))
          else
            for (final product in store.products)
              Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.category),
                  trailing: Text(store.formatRupiah(product.price)),
                ),
              ),
        ],
      ),
    );
  }
}
