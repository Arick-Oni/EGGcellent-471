import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/payments/models/wallet_models.dart';
import 'package:poultry_app/payments/data/wallet_repository.dart';

class FirestoreWalletRepository implements WalletRepository {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _walletRef(String uid) =>
      _db.collection('users').doc(uid).collection('wallet').doc('summary');

  CollectionReference<Map<String, dynamic>> _txRef(String uid) =>
      _db.collection('users').doc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> _ordersRef(String uid) =>
      _db.collection('users').doc(uid).collection('orders');

  @override
  Stream<WalletSummary> watchWallet(String uid) =>
      _walletRef(uid).snapshots().map(WalletSummary.fromDoc);

  @override
  Future<WalletSummary> getWalletOnce(String uid) async {
    final s = await _walletRef(uid).get();
    return WalletSummary.fromDoc(s);
  }

  @override
  Stream<List<MoneyTransaction>> watchTransactions(String uid) => _txRef(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(MoneyTransaction.fromDoc).toList());

  @override
  Stream<List<OrderRecord>> watchOrders(String uid) => _ordersRef(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(OrderRecord.fromDoc).toList());

  @override
  Future<void> addMoney({
    required String uid,
    required int amountTk,
    required PaymentMethod method,
  }) async {
    final txDoc = _txRef(uid).doc();
    await _db.runTransaction((txn) async {
      final wRef = _walletRef(uid);
      final wSnap = await txn.get(wRef);
      final current =
          wSnap.exists ? WalletSummary.fromDoc(wSnap) : WalletSummary.empty;

      txn.set(wRef, {'balance': current.balance + amountTk},
          SetOptions(merge: true));
      txn.set(txDoc, {
        'type': MoneyTxType.addMoney.name,
        'amount': amountTk,
        'method': method.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  @override
  Future<String> createOrderAndPay({
    required String uid,
    required List<OrderItem> items,
    required int pointsToUse,
  }) async {
    final orderDoc = _ordersRef(uid).doc();
    await orderDoc.set({
      'items': items.map((e) => e.toMap()).toList(),
      'total': items.fold<int>(0, (p, e) => p + e.lineTotal),
      'pointsUsed': 0,
      'amountPaid': 0,
      'paymentOption': 'pending',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
    return orderDoc.id;
  }

  // expose refs for WalletService combo transaction
  DocumentReference<Map<String, dynamic>> walletRef(String uid) =>
      _walletRef(uid);
  CollectionReference<Map<String, dynamic>> txRef(String uid) => _txRef(uid);
  DocumentReference<Map<String, dynamic>> orderRef(
          String uid, String orderId) =>
      _ordersRef(uid).doc(orderId);
}
