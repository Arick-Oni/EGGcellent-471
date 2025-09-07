import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// Create a TOP-LEVEL /orders document.
  /// Your rules require buyerId == auth.uid and you should include sellerId.
  Future<DocumentReference<Map<String, dynamic>>> createOrder({
    required String itemId,
    required String title,
    required String sellerId,
    required int quantity,
    required int unitPriceTk,
    required String deliveryAddress,
  }) async {
    final totalTk = quantity * unitPriceTk;

    final doc = _db.collection('orders').doc(); // /orders/{orderId}
    await doc.set({
      'orderId': doc.id,
      'buyerId': uid, // REQUIRED by rules (must equal auth.uid)
      'sellerId': sellerId, // lets seller read/update
      'itemId': itemId,
      'title': title,
      'qty': quantity,
      'unitPriceTk': unitPriceTk,
      'totalTk': totalTk,
      'deliveryAddress': deliveryAddress,
      'status': 'pending_payment', // then set to 'paid' after pay
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    return doc;
  }

  /// Convenience stream: all orders where I'm the buyer.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyOrders() {
    return _db
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Optional helper to update status (e.g., seller fulfills).
  Future<void> updateStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
