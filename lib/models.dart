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

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };
}

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        qty: (json['qty'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'qty': qty,
      };

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

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        customer: json['customer'] as String,
        items: (json['items'] as List)
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toInt(),
        time: DateTime.parse(json['time'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'time': time.toIso8601String(),
      };
}
