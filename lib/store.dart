import 'models.dart';

class Store {
  Store._();
  static final Store instance = Store._();

  final List<User> users = const [
    User(username: 'admin', password: 'admin', role: Role.admin),
    User(username: 'kasir', password: 'kasir', role: Role.kasir),
    User(username: 'customer', password: 'customer', role: Role.customer),
  ];

  final List<Product> products = [
    const Product(id: 'P01', name: 'Nasi Goreng', price: 15000),
    const Product(id: 'P02', name: 'Mie Ayam', price: 12000),
    const Product(id: 'P03', name: 'Ayam Geprek', price: 18000),
    const Product(id: 'P04', name: 'Es Teh', price: 5000),
    const Product(id: 'P05', name: 'Kopi Susu', price: 10000),
    const Product(id: 'P06', name: 'Roti Bakar', price: 8000),
  ];

  final List<Transaction> transactions = [
    Transaction(
      id: 'TRX-001',
      customer: 'Budi',
      items: [
        CartItem(product: const Product(id: 'P01', name: 'Nasi Goreng', price: 15000), qty: 2),
      ],
      total: 30000,
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Transaction(
      id: 'TRX-002',
      customer: 'Siti',
      items: [
        CartItem(product: const Product(id: 'P02', name: 'Mie Ayam', price: 12000), qty: 1),
        CartItem(product: const Product(id: 'P04', name: 'Es Teh', price: 5000), qty: 2),
      ],
      total: 22000,
      time: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  int revenue() => transactions.fold(0, (sum, t) => sum + t.total);

  String formatRupiah(int v) => 'Rp ${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
}
