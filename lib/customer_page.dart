import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final Store store = Store.instance;
  final cart = <CartItem>[];
  final customerNameController = TextEditingController(text: 'Pelanggan');
  String search = '';

  int get total => cart.fold(0, (sum, item) => sum + item.subtotal);

  List<Product> get filteredProducts => store.products.where((product) {
        return product.name.toLowerCase().contains(search.toLowerCase());
      }).toList();

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

  Future<void> checkout() async {
    if (cart.isEmpty) return;
    await store.submitCustomerOrder(customerNameController.text, cart.toList());
    if (!mounted) return;

    setState(() => cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan dikirim ke kasir')),
    );
  }

  @override
  void dispose() {
    customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = cart.fold(0, (sum, item) => sum + item.qty);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Kantin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(
                hintText: 'Cari menu',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('Menu tidak ditemukan'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 32,
                                    child: Icon(
                                      product.category == 'Minuman'
                                          ? Icons.local_cafe
                                          : Icons.fastfood,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              Text(product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(child: Text(store.formatRupiah(product.price))),
                                  IconButton(
                                    onPressed: () => addProduct(product),
                                    icon: const Icon(Icons.add_circle),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama pelanggan',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: cart.isEmpty ? null : checkout,
                    child: Text('Pesan • ${store.formatRupiah(total)} ($cartCount)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
