import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'services/firestore_service.dart';

class Store {
  Store._();
  static final Store instance = Store._();

  static const _productsKey = 'kantin_products';
  static const _transactionsKey = 'kantin_transactions';

  late SharedPreferences _prefs;

  final List<User> users = const [
    User(username: 'admin', password: 'admin', role: Role.admin),
    User(username: 'kasir', password: 'kasir', role: Role.kasir),
    User(username: 'customer', password: 'customer', role: Role.customer),
  ];

  List<Product> products = [];
  List<Transaction> transactions = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    products = _loadProducts();
    transactions = _loadTransactions();
  }

  List<Product> _loadProducts() {
    final raw = _prefs.getString(_productsKey);
    if (raw == null || raw.isEmpty) return _defaultProducts;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultProducts;
    }
  }

  List<Transaction> _loadTransactions() {
    final raw = _prefs.getString(_transactionsKey);
    if (raw == null || raw.isEmpty) return _defaultTransactions;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) => Transaction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultTransactions;
    }
  }

  Future<void> persist() async {
    await Future.wait([
      _prefs.setString(_productsKey, jsonEncode(products.map((product) => product.toJson()).toList())),
      _prefs.setString(
        _transactionsKey,
        jsonEncode(transactions.map((transaction) => transaction.toJson()).toList()),
      ),
    ]);
  }

  String createProductId() => 'P${DateTime.now().microsecondsSinceEpoch}';

  String createTransactionId() => 'TRX-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> submitCustomerOrder(String customerName, List<CartItem> items) async {
    if (items.isEmpty) return;

    final order = Order(
      id: 'ORD-${DateTime.now().microsecondsSinceEpoch}',
      customerName: customerName.trim().isEmpty ? 'Pelanggan' : customerName.trim(),
      cashierName: 'Kasir',
      items: items.map((item) => OrderItem(product: item.product, qty: item.qty)).toList(),
      total: items.fold<int>(0, (sum, item) => sum + item.subtotal),
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
    );

    final isCloudReady = await FirestoreService.instance.isReadyCheck();
    if (isCloudReady) {
      await FirestoreService.instance.addOrder(order);
      return;
    }

    final transaction = Transaction(
      id: createTransactionId(),
      customer: order.customerName,
      items: items.map((item) => CartItem(product: item.product, qty: item.qty)).toList(),
      total: order.total,
      time: DateTime.now(),
    );

    transactions.add(transaction);
    await persist();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final isCloudReady = await FirestoreService.instance.isReadyCheck();
    if (!isCloudReady) return;
    await FirestoreService.instance.updateOrderStatus(orderId, status);
  }

  Stream<List<Order>> watchOrders() async* {
    final cloudReady = await FirestoreService.instance.isReadyCheck();
    if (cloudReady) {
      yield* FirestoreService.instance.watchOrders();
      return;
    }

    final fallback = transactions
        .map((transaction) => Order(
              id: transaction.id,
              customerName: transaction.customer,
              cashierName: 'Kasir',
              items: transaction.items
                  .map((item) => OrderItem(product: item.product, qty: item.qty))
                  .toList(),
              total: transaction.total,
              createdAt: transaction.time,
              status: OrderStatus.pending,
            ))
        .toList();
    yield fallback;
  }

  List<Product> get _defaultProducts => const [
        Product(id: 'P01', name: 'Nasi Goreng', price: 15000, category: 'Makanan'),
        Product(id: 'P02', name: 'Mie Ayam', price: 12000, category: 'Makanan'),
        Product(id: 'P03', name: 'Ayam Geprek', price: 18000, category: 'Makanan'),
        Product(id: 'P04', name: 'Es Teh', price: 5000, category: 'Minuman'),
        Product(id: 'P05', name: 'Kopi Susu', price: 10000, category: 'Minuman'),
        Product(id: 'P06', name: 'Roti Bakar', price: 8000, category: 'Camilan'),
      ];

  List<Transaction> get _defaultTransactions => [
        Transaction(
          id: 'TRX-001',
          customer: 'Budi',
          items: [CartItem(product: const Product(id: 'P01', name: 'Nasi Goreng', price: 15000, category: 'Makanan'), qty: 2)],
          total: 30000,
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Transaction(
          id: 'TRX-002',
          customer: 'Siti',
          items: [
            CartItem(product: const Product(id: 'P02', name: 'Mie Ayam', price: 12000, category: 'Makanan'), qty: 1),
            CartItem(product: const Product(id: 'P04', name: 'Es Teh', price: 5000, category: 'Minuman'), qty: 2),
          ],
          total: 22000,
          time: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

  int revenue() => transactions.fold(0, (sum, transaction) => sum + transaction.total);

  String formatRupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
}
