import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'kasir_page.dart';
import 'customer_page.dart';
import 'admin_page.dart';

class DashboardPage extends StatelessWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  List<int> _dailyRevenue(Store store) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
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
    final colors = theme.colorScheme;
    final revenues = _dailyRevenue(store);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F4),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text('Kantin Kita', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: '${user.username} • ${user.role}',
              child: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.primary,
                child: Text(user.username.isEmpty ? '?' : user.username[0].toUpperCase()),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 12, wide ? 32 : 20, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _welcomeCard(context),
                      const SizedBox(height: 28),
                      _sectionHeading(context, 'Ringkasan hari ini', 'Performa kantin dalam sekejap'),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: wide ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: wide ? 2.15 : 1.55,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _statCard(context, Icons.inventory_2_rounded, 'Produk', '${store.products.length}', const Color(0xFFE7F3ED)),
                          _statCard(context, Icons.receipt_long_rounded, 'Transaksi', '${store.transactions.length}', const Color(0xFFFFF1D9)),
                          _statCard(context, Icons.payments_rounded, 'Pendapatan', store.formatRupiah(store.revenue()), const Color(0xFFE8EDFF)),
                        ],
                      ),
                      const SizedBox(height: 26),
                      _sectionHeading(context, 'Aktivitas penjualan', 'Pendapatan 7 hari terakhir'),
                      const SizedBox(height: 14),
                      _revenueCard(context, revenues),
                      const SizedBox(height: 26),
                      _sectionHeading(context, 'Akses cepat', 'Pilih aktivitas yang ingin dilakukan'),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: wide ? 3 : 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: wide ? 1.65 : 3.2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          if (user.role == Role.admin)
                            _actionCard(context, Icons.tune_rounded, 'Admin', 'Kelola produk dan transaksi', const Color(0xFFE7F3ED), const AdminPage()),
                          if (user.role == Role.admin || user.role == Role.kasir)
                            _actionCard(context, Icons.point_of_sale_rounded, 'Kasir', 'Mulai transaksi penjualan', const Color(0xFFFFF1D9), const KasirPage()),
                          if (user.role == Role.customer || user.role == Role.kasir)
                            _actionCard(context, Icons.storefront_rounded, 'Menu kantin', 'Lihat menu dan buat pesanan', const Color(0xFFE8EDFF), const CustomerPage()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF176B4D), Color(0xFF23956A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF176B4D).withValues(alpha: 0.18), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DASHBOARD KASIR', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Halo, ${user.username}!', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Siap melayani pelanggan hari ini?', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.86))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 31),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1F2D27))),
        const SizedBox(height: 3),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF78837D))),
      ],
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String label, String value, Color iconBackground) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EDE9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 20, color: const Color(0xFF176B4D)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF78837D))),
              const SizedBox(height: 3),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1F2D27))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenueCard(BuildContext context, List<int> revenues) {
    final theme = Theme.of(context);
    final maxRevenue = revenues.fold<int>(0, (current, value) => value > current ? value : current);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE9EDE9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text('Tren pendapatan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
              const Icon(Icons.trending_up_rounded, color: Color(0xFF23956A)),
            ],
          ),
          const SizedBox(height: 4),
          Text(maxRevenue == 0 ? 'Belum ada transaksi minggu ini' : 'Puncak harian ${Store.instance.formatRupiah(maxRevenue)}', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF78837D))),
          const SizedBox(height: 14),
          SizedBox(
            height: 142,
            width: double.infinity,
            child: CustomPaint(painter: _RevenuePainter(values: revenues, color: const Color(0xFF23956A))),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
              return Text(labels[date.weekday % 7], style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF78837D)));
            }),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String title, String subtitle, Color iconBackground, Widget page) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EDE9))),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, color: const Color(0xFF176B4D)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF78837D))),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 19, color: Color(0xFF78837D)),
            ],
          ),
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

    final grid = Paint()..color = const Color(0xFFE9EDE9)..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = verticalPadding + height * index / 3;
      canvas.drawLine(Offset(horizontalPadding, y), Offset(size.width - horizontalPadding, y), grid);
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
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height - verticalPadding)
      ..lineTo(points.first.dx, size.height - verticalPadding)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.01)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .createShader(Offset.zero & size),
    );
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
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenuePainter oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}
