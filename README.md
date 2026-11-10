import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'kasir_page.dart';
import 'customer_page.dart';
import 'admin_page.dart';

class DashboardPage extends StatelessWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text('${user.username} • ${user.role}'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${user.username}!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Anda login sebagai ${user.role}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _statCard(context, Icons.inventory_2, 'Produk', '${store.products.length}'),
                const SizedBox(width: 12),
                _statCard(context, Icons.receipt_long, 'Transaksi', '${store.transactions.length}'),
                const SizedBox(width: 12),
                _statCard(context, Icons.payments, 'Pendapatan', store.formatRupiah(store.revenue())),
              ],
            ),
            const SizedBox(height: 24),
            Text('Menu', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (user.role == Role.kasir)
              _menuTile(context, Icons.shopping_cart, 'Kasir', 'Buat transaksi penjualan', const KasirPage()),
            if (user.role == Role.admin)
              _menuTile(context, Icons.settings, 'Admin', 'Kelola produk & lihat laporan', const AdminPage()),
            if (user.role == Role.customer)
              _menuTile(context, Icons.storefront, 'Menu Kantin', 'Lihat menu & pesan', const CustomerPage()),
            if (user.role == Role.admin)
              _menuTile(context, Icons.shopping_cart, 'Kasir', 'Buat transaksi penjualan', const KasirPage()),
            if (user.role == Role.kasir)
              _menuTile(context, Icons.storefront, 'Menu Kantin', 'Lihat menu', const CustomerPage()),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
