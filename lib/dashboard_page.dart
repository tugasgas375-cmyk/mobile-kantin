import 'package:flutter/material.dart';

import 'admin_page.dart';
import 'customer_page.dart';
import 'kasir_page.dart';
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
          .where((transaction) => transaction.time.year == date.year &&
              transaction.time.month == date.month &&
              transaction.time.day == date.day)
          .fold<int>(0, (sum, transaction) => sum + transaction.total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final revenues = _dailyRevenue(store);
    final todayRevenue = revenues.last;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KANTIN POS', style: TextStyle(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: Color(0xFFB84A24))),
            Text('Ringkasan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFEDE9E2))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(radius: 12, backgroundColor: scheme.primaryContainer, child: Icon(Icons.person_rounded, size: 14, color: scheme.primary)),
                  const SizedBox(width: 7),
                  Text(user.username, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 12, wide ? 32 : 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF332B26), Color(0xFF514137)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    Positioned(right: -10, top: -22, child: Icon(Icons.restaurant_rounded, size: 130, color: Colors.white.withValues(alpha: .07))),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                        child: Text('HARI INI  ·  ${_formatDate(DateTime.now())}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 18),
                      Text('Halo, ${user.username} 👋', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                      const SizedBox(height: 6),
                      const Text('Semoga aktivitas kantinmu lancar hari ini.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 22),
                      Text(store.formatRupiah(todayRevenue), style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w800, letterSpacing: -.7)),
                      const SizedBox(height: 2),
                      const Text('PENDAPATAN HARI INI', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Performa bisnis', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.3)),
                Text('Semua waktu', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey.shade600)),
              ]),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _statCard(context, Icons.inventory_2_outlined, 'Produk aktif', '${store.products.length}', const Color(0xFF477A63)),
                  _statCard(context, Icons.receipt_long_outlined, 'Transaksi', '${store.transactions.length}', const Color(0xFF5977A8)),
                  _statCard(context, Icons.account_balance_wallet_outlined, 'Total omzet', store.formatRupiah(store.revenue()), const Color(0xFFB84A24)),
                ],
              ),
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('Tren pendapatan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: .55), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.show_chart_rounded, color: scheme.primary, size: 19)),
                    ]),
                    const SizedBox(height: 4),
                    Text('7 hari terakhir', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 14),
                    SizedBox(height: 145, width: double.infinity, child: CustomPaint(painter: _RevenuePainter(values: revenues, color: scheme.primary))),
                    const SizedBox(height: 5),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(7, (index) {
                      final date = DateTime.now().subtract(Duration(days: 6 - index));
                      const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
                      return Text(labels[date.weekday % 7], style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade600));
                    })),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              Text('Akses cepat', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.3)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: wide ? 3 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: wide ? 2.4 : 3.2,
                children: [
                  if (user.role == Role.admin) _actionCard(context, Icons.tune_rounded, 'Kelola produk', 'Atur menu dan transaksi', const AdminPage(), const Color(0xFF477A63)),
                  if (user.role == Role.admin || user.role == Role.kasir) _actionCard(context, Icons.point_of_sale_rounded, 'Mulai transaksi', 'Layani pesanan kantin', const KasirPage(), const Color(0xFFB84A24)),
                  if (user.role == Role.customer || user.role == Role.kasir) _actionCard(context, Icons.restaurant_menu_rounded, 'Jelajahi menu', 'Pilih makanan favorit', const CustomerPage(), const Color(0xFF5977A8)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  Widget _statCard(BuildContext context, IconData icon, String label, String value, Color accent) {
    return SizedBox(
      width: 205,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: accent, size: 21)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey.shade600)),
              const SizedBox(height: 3),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String title, String subtitle, Widget page, Color accent) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: accent.withValues(alpha: .1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: accent)),
            const SizedBox(width: 13),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ]),
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
    final maxValue = values.fold<int>(0, (max, value) => value > max ? value : max);
    final scale = maxValue == 0 ? 1.0 : maxValue.toDouble();
    final grid = Paint()..color = const Color(0xFFEFEAE4)..strokeWidth = 1;
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
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(colors: [color.withValues(alpha: .18), color.withValues(alpha: .01)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & size));
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3.2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenuePainter oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}
