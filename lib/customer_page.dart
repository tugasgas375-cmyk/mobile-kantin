import 'package:flutter/material.dart';

import 'store.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Kantin')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: store.products.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final p = store.products[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.fastfood)),
            title: Text(p.name),
            trailing: Text(
              store.formatRupiah(p.price),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
