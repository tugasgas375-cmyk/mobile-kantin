import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

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

  List<Product> get _defaultProducts => const [
        Product(id: 'P01', name: 'Nasi Goreng', price: 15000),
        Product(id: 'P02', name: 'Mie Ayam', price: 12000),
        Product(id: 'P03', name: 'Ayam Geprek', price: 18000),
        Product(id: 'P04', name: 'Es Teh', price: 5000),
        Product(id: 'P05', name: 'Kopi Susu', price: 10000),
        Product(id: 'P06', name: 'Roti Bakar', price: 8000),
      ];

  List<Transaction> get _defaultTransactions => [
        Transaction(
          id: 'TRX-001',
          customer: 'Budi',
          items: [CartItem(product: const Product(id: 'P01', name: 'Nasi Goreng', price: 15000), qty: 2)],
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

  int revenue() => transactions.fold(0, (sum, transaction) => sum + transaction.total);

  String formatRupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
}
