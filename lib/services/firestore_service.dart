import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isReadyCheck() async {
    try {
      await FirebaseFirestore.instance.enableNetwork();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> addOrder(Order order) async {
    await _db.collection('orders').doc(order.id).set(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({'status': status.name});
  }

  Stream<List<Order>> watchOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Order.fromJson({...doc.data(), 'id': doc.id});
            }).toList());
  }
}
