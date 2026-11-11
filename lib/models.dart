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
  final String category;

  const Product({required this.id, required this.name, required this.price, this.category = 'Lainnya'});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        category: json['category'] as String? ?? 'Lainnya',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price, 'category': category};
}

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        qty: (json['qty'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'qty': qty};

  int get subtotal => product.price * qty;
}

class Transaction {
  final String id;
  final String customer;
  final List<CartItem> items;
  final int total;
  final DateTime time;

  Transaction({required this.id, required this.customer, required this.items, required this.total, required this.time});

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

enum OrderStatus { pending, processing, ready, completed }

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Menunggu';
    case OrderStatus.processing:
      return 'Diproses';
    case OrderStatus.ready:
      return 'Siap';
    case OrderStatus.completed:
      return 'Selesai';
  }
}

OrderStatus orderStatusFromString(String? value) {
  switch (value) {
    case 'processing':
      return OrderStatus.processing;
    case 'ready':
      return OrderStatus.ready;
    case 'completed':
      return OrderStatus.completed;
    case 'pending':
    default:
      return OrderStatus.pending;
  }
}

class OrderItem {
  final Product product;
  int qty;

  OrderItem({required this.product, this.qty = 1});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        qty: (json['qty'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'qty': qty};

  int get subtotal => product.price * qty;
}

class Order {
  final String id;
  final String customerName;
  final String cashierName;
  final List<OrderItem> items;
  final int total;
  final DateTime createdAt;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.customerName,
    required this.cashierName,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String? ?? json['orderId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? 'Pelanggan',
        cashierName: json['cashierName'] as String? ?? 'Kasir',
        items: (json['items'] as List? ?? const [])
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num? ?? 0).toInt(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        status: orderStatusFromString(json['status'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'cashierName': cashierName,
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };
}
