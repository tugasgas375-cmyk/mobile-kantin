import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class DashboardPage extends StatelessWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  List<int> _dailyRevenue(Store store) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index));
      return store.transactions
          .where(
            (transaction) =>
                transaction.time.year == date.year &&
                transaction.time.month == date.month &&
                transaction.time.day == date.day,
          )
          .fold<int>(0, (sum, transaction) => sum + transaction.total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final theme = Theme.of(context);
    final revenues = _dailyRevenue(store);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.person_rounded, size: 18),
              label: Text('${user.username} • ${user.role}'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Halo, ${user.username}!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda login sebagai ${user.role}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text('Ringkasan', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statCard(
                context,
                Icons.inventory_2_rounded,
                'Produk',
                '${store.products.length}',
              ),
              _statCard(
                context,
                Icons.receipt_long_rounded,
                'Transaksi',
                '${store.transactions.length}',
              ),
              _statCard(
                context,
                Icons.payments_rounded,
                'Pendapatan',
                store.formatRupiah(store.revenue()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendapatan 7 hari terakhir',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _RevenuePainter(
                        values: revenues,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final date = DateTime.now().subtract(Duration(days: 6 - index));
                      const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
                      return Text(
                        labels[date.weekday % 7],
                        style: theme.textTheme.labelSmall,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Menu', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (user.role == Role.admin)
            _menuTile(
              context,
              Icons.settings_rounded,
              'Admin',
              'Kelola produk dan lihat transaksi',
              const AdminPage(),
            ),
          if (user.role == Role.admin || user.role == Role.kasir)
            _menuTile(
              context,
              Icons.shopping_cart_rounded,
              'Kasir',
              'Buat transaksi penjualan',
              const KasirPage(),
            ),
          if (user.role == Role.customer || user.role == Role.kasir)
            _menuTile(
              context,
              Icons.storefront_rounded,
              'Menu Kantin',
              'Lihat menu dan buat pesanan',
              const CustomerPage(),
            ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}

class _RevenuePainter extends CustomPainter {
  final List<int> values;
  final Color color;

  const _RevenuePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;

    const horizontalPadding = 8.0;
    const verticalPadding = 12.0;
    final width = size.width - horizontalPadding * 2;
    final height = size.height - verticalPadding * 2;
    final maximum = values.fold<int>(0, (current, value) => value > current ? value : current);
    final scale = maximum == 0 ? 1.0 : maximum.toDouble();

    final grid = Paint()
      ..color = color.withAlpha(36)
      ..strokeWidth = 1;

    for (var index = 0; index < 4; index++) {
      final y = verticalPadding + height * index / 3;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        grid,
      );
    }

    final points = List.generate(values.length, (index) {
      final x = horizontalPadding + width * index / (values.length - 1);
      final y = verticalPadding + height - values[index] / scale * height;
      return Offset(x, y);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenuePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
