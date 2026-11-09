class Role {
  static const admin = 'Admin';
  static const kasir = 'Kasir';
  static const customer = 'Customer';
}

class User {
  final String username;
  final String password;
  final String role;

  const User({required this.username, required this.password, required this.role});
}

class Product {
  final String id;
  final String name;
  final int price;

  const Product({required this.id, required this.name, required this.price});
}

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  int get subtotal => product.price * qty;
}

class Transaction {
  final String id;
  final String customer;
  final List<CartItem> items;
  final int total;
  final DateTime time;

  Transaction({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.time,
  });
}
