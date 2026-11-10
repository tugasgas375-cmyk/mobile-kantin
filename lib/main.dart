import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'kasir_page.dart';
import 'customer_page.dart';
import 'admin_page.dart';

class DashboardPage extends StatelessWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  List<int> _weeklyRevenue(Store store) {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - index));
      return store.transactions
          .where((transaction) =>
              transaction.time.year == date.year &&
              transaction.time.month == date.month &&
              transaction.time.day == date.day)
          .fold<int>(0, (sum, transaction) => sum + transaction.total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final theme = Theme.of(context);
    final weeklyRevenue = _weeklyRevenue(store);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantin Kita', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.person_outline, size: 18),
              label: Text('${user.username} • ${user.role}'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              if (!context.mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.waving_hand_outlined, color: Colors.white, size: 28),
                const SizedBox(height: 14),
                Text('Halo, ${user.username}!',
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Senang melihatmu kembali • ${user.role}', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Ringkasan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              final cards = [
                _StatCard(icon: Icons.restaurant_menu, title: 'Produk', value: '${store.products.length}', color: Colors.orange),
                _StatCard(icon: Icons.receipt_long, title: 'Transaksi', value: '${store.transactions.length}', color: Colors.blue),
                _StatCard(icon: Icons.account_balance_wallet_outlined, title: 'Pendapatan', value: store.formatRupiah(store.revenue()), color: Colors.green),
              ];
              if (compact) {
                return Column(
                  children: cards
                      .map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SizedBox(width: double.infinity, child: card),
                          ))
                      .toList(),
                );
              }
              return Row(
                children: [
                  for (var index = 0; index < cards.length; index++) ...[
                    if (index > 0) const SizedBox(width: 10),
                    Expanded(child: cards[index]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pendapatan 7 hari terakhir', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Pergerakan pemasukan harian', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(painter: _RevenueChartPainter(values: weeklyRevenue, color: theme.colorScheme.primary)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final day = DateTime.now().subtract(Duration(days: 6 - index));
                      const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
                      return Text(labels[day.weekday % 7], style: theme.textTheme.labelSmall);
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Menu utama', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (user.role == Role.admin)
            _menuTile(context, Icons.tune, 'Kelola kantin', 'Atur produk dan lihat transaksi', const AdminPage()),
          if (user.role == Role.admin || user.role == Role.kasir)
            _menuTile(context, Icons.point_of_sale, 'Kasir', 'Buat transaksi penjualan', const KasirPage()),
          if (user.role == Role.customer || user.role == Role.kasir)
            _menuTile(context, Icons.storefront, 'Menu kantin', 'Cari menu dan buat pesanan', const CustomerPage()),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final List<int> values;
  final Color color;

  const _RevenueChartPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;

    const left = 8.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 12.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final scaleMax = maxValue == 0 ? 1.0 : maxValue;

    final gridPaint = Paint()..color = color.withOpacity(0.12)..strokeWidth = 1;
    for (var line = 0; line < 4; line++) {
      final y = top + chartHeight * line / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
    }

    final points = List.generate(values.length, (index) {
      final x = left + chartWidth * index / (values.length - 1);
      final y = top + chartHeight - ((values[index] / scaleMax) * chartHeight);
      return Offset(x, y);
    });

    final fillPath = Path()
      ..moveTo(points.first.dx, top + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, top + chartHeight)
      ..close();

    final gradient = LinearGradient(
      colors: [color.withOpacity(0.28), color.withOpacity(0.02)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, top, size.width, chartHeight)),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final pointPaint = Paint()..color = color;
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
