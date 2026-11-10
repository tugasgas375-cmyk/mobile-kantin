import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final store = Store.instance;
  final cart = <CartItem>[];
  final customerCtrl = TextEditingController();
  bool _saving = false;

  void _add(Product product) {
    setState(() {
      final existing = cart.firstWhereOrNull((item) => item.product.id == product.id);
      if (existing == null) {
        cart.add(CartItem(product: product));
      } else {
        existing.qty++;
      }
    });
  }

  void _change(CartItem item, int delta) {
    setState(() {
      item.qty += delta;
      if (item.qty <= 0) cart.remove(item);
    });
  }

  int get total => cart.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> _checkout() async {
    if (cart.isEmpty || _saving) return;
    setState(() => _saving = true);
    final transaction = Transaction(
      id: store.createTransactionId(),
      customer: customerCtrl.text.trim().isEmpty ? 'Umum' : customerCtrl.text.trim(),
      items: cart.map((item) => CartItem(product: item.product, qty: item.qty)).toList(),
      total: total,
      time: DateTime.now(),
    );
    try {
      store.transactions.add(transaction);
      await store.persist();
      if (!mounted) return;
      setState(() {
        cart.clear();
        customerCtrl.clear();
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi berhasil · ${store.formatRupiah(transaction.total)}')));
    } catch (error) {
      store.transactions.removeWhere((item) => item.id == transaction.id);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi gagal: $error')));
    }
  }

  Future<void> _advanceOrder(Order order) async {
    final nextStatus = switch (order.status) {
      OrderStatus.pending => OrderStatus.processing,
      OrderStatus.processing => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.completed,
      OrderStatus.completed => OrderStatus.completed,
    };
    try {
      await store.updateOrderStatus(order.id, nextStatus);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status gagal diperbarui: $error')));
    }
  }

  @override
  void dispose() {
    customerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('KANTIN POS', style: TextStyle(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: Color(0xFFB84A24))),
        Text('Kasir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ])),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth > 850;
        final menu = _buildMenu(context);
        final orderQueue = _buildOrders(context);
        final checkout = _buildCheckout(context);
        if (wide) {
          return Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 6, child: Column(children: [Expanded(child: menu), const SizedBox(height: 14), Expanded(child: orderQueue)])),
            const SizedBox(width: 18),
            SizedBox(width: 370, child: checkout),
          ]));
        }
        return Column(children: [
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 20), children: [menu, const SizedBox(height: 20), orderQueue])),
          checkout,
        ]);
      }),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(context, 'Tambah ke pesanan', 'Pilih produk untuk keranjang'),
      const SizedBox(height: 12),
      if (store.products.isEmpty)
        const _EmptyCard(icon: Icons.inventory_2_outlined, title: 'Belum ada produk', subtitle: 'Produk akan muncul di sini setelah ditambahkan.')
      else
        Wrap(spacing: 10, runSpacing: 10, children: store.products.map((product) => SizedBox(
          width: 170,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: () => _add(product), child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(product.category == 'Minuman' ? Icons.local_cafe_rounded : Icons.lunch_dining_rounded, color: theme.colorScheme.primary, size: 20)),
              const SizedBox(height: 11),
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(children: [Expanded(child: Text(store.formatRupiah(product.price), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12))), const Icon(Icons.add_circle_rounded, size: 20)]),
            ]))),
          ),
        )).toList()),
    ]);
  }

  Widget _buildOrders(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(context, 'Pesanan online', 'Status pesanan pelanggan'),
      const SizedBox(height: 12),
      StreamBuilder<List<Order>>(
        stream: store.watchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const _EmptyCard(icon: Icons.cloud_off_rounded, title: 'Pesanan tidak tersedia', subtitle: 'Periksa koneksi atau konfigurasi Firebase.');
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
          final orders = snapshot.data ?? const <Order>[];
          if (orders.isEmpty) return const _EmptyCard(icon: Icons.receipt_long_outlined, title: 'Belum ada pesanan masuk', subtitle: 'Pesanan online pelanggan akan tampil di sini.');
          return Column(children: orders.map((order) {
            final canAdvance = order.status != OrderStatus.completed;
            return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))), _statusChip(order.status)]),
              const SizedBox(height: 8),
              Text(order.items.map((item) => '${item.product.name} × ${item.qty}').join('  ·  '), style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 11),
              Row(children: [Expanded(child: Text(store.formatRupiah(order.total), style: const TextStyle(fontWeight: FontWeight.w800))), if (canAdvance) TextButton.icon(onPressed: () => _advanceOrder(order), icon: const Icon(Icons.arrow_forward_rounded, size: 17), label: Text(_nextStatusLabel(order.status)))]),
            ])));
          }).toList());
        },
      ),
    ]);
  }

  Widget _buildCheckout(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Expanded(child: Text('Pesanan saat ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)), child: Text('${cart.length} item', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12)))]),
          const SizedBox(height: 14),
          TextField(controller: customerCtrl, decoration: const InputDecoration(labelText: 'Nama pelanggan', prefixIcon: Icon(Icons.person_outline_rounded))),
          const SizedBox(height: 12),
          Expanded(child: cart.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_basket_outlined, size: 42, color: Colors.grey.shade400), const SizedBox(height: 8), Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey.shade600))]))
              : ListView.separated(itemCount: cart.length, separatorBuilder: (_, _) => const Divider(height: 1), itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(contentPadding: EdgeInsets.zero, title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(store.formatRupiah(item.subtotal)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: 'Kurangi', onPressed: () => _change(item, -1), icon: const Icon(Icons.remove_circle_outline_rounded)), Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w700)), IconButton(tooltip: 'Tambah', onPressed: () => _change(item, 1), icon: const Icon(Icons.add_circle_outline_rounded))]));
                })),
          const Divider(height: 24),
          Row(children: [const Expanded(child: Text('Total pembayaran', style: TextStyle(color: Colors.black54))), Text(store.formatRupiah(total), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))]),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: cart.isEmpty || _saving ? null : _checkout, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.payments_outlined), label: Text(_saving ? 'Menyimpan...' : 'Selesaikan transaksi'))),
        ]),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]);

  Widget _statusChip(OrderStatus status) {
    final (label, color) = switch (status) {
      OrderStatus.pending => ('Menunggu', const Color(0xFFAD6B00)),
      OrderStatus.processing => ('Diproses', const Color(0xFF5977A8)),
      OrderStatus.ready => ('Siap', const Color(0xFF477A63)),
      OrderStatus.completed => ('Selesai', const Color(0xFF68645E)),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)));
  }

  String _nextStatusLabel(OrderStatus status) => switch (status) {
        OrderStatus.pending => 'Mulai proses',
        OrderStatus.processing => 'Tandai siap',
        OrderStatus.ready => 'Selesaikan',
        OrderStatus.completed => 'Selesai',
      };
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [Icon(icon, color: Colors.grey.shade500, size: 30), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]))])));
}

extension IterableFirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
