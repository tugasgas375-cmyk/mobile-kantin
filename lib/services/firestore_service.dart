import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<bool> isReady() async {
    try {
      if (kIsWeb) {
        return false;
      }
      await _db.collection('orders').limit(1).get();
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<List<Order>> watchOrders() {
    try {
      if (kIsWeb) return const Stream.empty();
      return _db
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Order.fromJson({...doc.data(), 'id': doc.id}))
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> addOrder(Order order) async {
    if (!await isReady()) return;
    await _db.collection('orders').doc(order.id).set(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (!await isReady()) return;
    await _db.collection('orders').doc(orderId).update({'status': status.name});
  }
}
