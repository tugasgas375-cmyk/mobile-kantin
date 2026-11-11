import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<bool> isReadyCheck() async {
    if (_isReady) return true;
    try {
      await FirebaseFirestore.instance.enableNetwork();
      _isReady = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> addOrder(Order order) async {
    final ready = await isReadyCheck();
    if (!ready) return;

    await _db.collection('orders').doc(order.id).set(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final ready = await isReadyCheck();
    if (!ready) return;

    await _db.collection('orders').doc(orderId).update({'status': status.name});
  }

  Stream<List<Order>> watchOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }
}
