import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/rewards/models/reward_models.dart';
import 'package:poultry_app/rewards/data/rewards_repository.dart';

class FirestoreRewardsRepository implements RewardsRepository {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _summaryRef(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('rewardsSummary')
      .doc('summary');

  CollectionReference<Map<String, dynamic>> _txRef(String uid) =>
      _db.collection('users').doc(uid).collection('rewardTransactions');

  @override
  Stream<UserPoints> watchSummary(String uid) =>
      _summaryRef(uid).snapshots().map(UserPoints.fromDoc);

  @override
  Stream<List<RewardTransaction>> watchTransactions(String uid) => _txRef(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(RewardTransaction.fromDoc).toList());

  @override
  Future<UserPoints> getSummaryOnce(String uid) async {
    final snap = await _summaryRef(uid).get();
    return UserPoints.fromDoc(snap);
  }

  @override
  Future<void> addEarnTransaction({
    required String uid,
    required RewardEvent event,
    required int points,
    Map<String, dynamic>? meta,
  }) async {
    if (points <= 0) throw ArgumentError('points must be > 0');
    final txDoc = _txRef(uid).doc();

    await _db.runTransaction((txn) async {
      final sRef = _summaryRef(uid);
      final sSnap = await txn.get(sRef);
      final now = DateTime.now();

      final current =
          sSnap.exists ? UserPoints.fromDoc(sSnap) : UserPoints.empty;

      txn.set(
          sRef,
          {
            'totalPoints': current.totalPoints + points,
            'lifetimePoints': current.lifetimePoints + points,
          },
          SetOptions(merge: true));

      txn.set(txDoc, {
        'type': event.name,
        'points': points,
        'createdAt': Timestamp.fromDate(now),
        if (meta != null) 'meta': meta,
      });
    });
  }

  @override
  Future<void> redeem({
    required String uid,
    required int points,
    Map<String, dynamic>? meta,
  }) async {
    if (points <= 0) throw ArgumentError('points must be > 0');
    final txDoc = _txRef(uid).doc();

    await _db.runTransaction((txn) async {
      final sRef = _summaryRef(uid);
      final sSnap = await txn.get(sRef);
      final current =
          sSnap.exists ? UserPoints.fromDoc(sSnap) : UserPoints.empty;
      if (current.totalPoints < points) throw StateError('Not enough points');

      txn.update(sRef, {'totalPoints': current.totalPoints - points});
      txn.set(txDoc, {
        'type': RewardEvent.redeem.name,
        'points': -points,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        if (meta != null) 'meta': meta,
      });
    });
  }

  // Helpers for timestamps used in service
  Future<void> setLastDailyLoginDate(String uid, DateTime date) =>
      _summaryRef(uid).set({'lastDailyLoginDate': Timestamp.fromDate(date)},
          SetOptions(merge: true));
  Future<void> setLastInteractionAt(String uid, DateTime date) =>
      _summaryRef(uid).set({'lastInteractionAt': Timestamp.fromDate(date)},
          SetOptions(merge: true));

  Future<UserPoints> getSummary(String uid) => getSummaryOnce(uid);
}
