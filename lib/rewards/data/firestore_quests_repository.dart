import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreQuestsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  DateTime _weekStart(DateTime date) {
    final dow = date.weekday; // Mon=1..Sun=7
    final start = date.subtract(Duration(days: dow - 1));
    return DateTime(start.year, start.month, start.day);
  }

  // Add explicit generics so snapshot.data() is Map<String, dynamic>?
  DocumentReference<Map<String, dynamic>> get _questsSummaryRef => _db
      .collection('users')
      .doc(uid)
      .collection('questsSummary')
      .doc('summary');

  DocumentReference<Map<String, dynamic>> get _rewardsSummaryRef => _db
      .collection('users')
      .doc(uid)
      .collection('rewardsSummary')
      .doc('summary');

  DocumentReference<Map<String, dynamic>> get _gamesSummaryRef => _db
      .collection('users')
      .doc(uid)
      .collection('gamesSummary')
      .doc('summary');

  CollectionReference<Map<String, dynamic>> get _rewardTransactionsRef =>
      _db.collection('users').doc(uid).collection('rewardTransactions');

  Future<void> ensureWeek() async {
    final now = DateTime.now();
    final weekStart = _weekStart(now);

    final doc = await _questsSummaryRef.get();
    final map = doc.data(); // Map<String, dynamic>?
    final weekStartRaw = map?['weekStartAt'];
    DateTime? lastWeekStart;

    if (weekStartRaw is Timestamp) {
      lastWeekStart = weekStartRaw.toDate();
    }

    if (lastWeekStart == null || lastWeekStart.isBefore(weekStart)) {
      await _questsSummaryRef.set({
        'weekStartAt': Timestamp.fromDate(weekStart),
        'browseCount': 0,
        'postCount': 0,
        'purchaseTk': 0,
        'ratingCount': 0,
        'completed': <String>[],
      }, SetOptions(merge: false));
    }
  }

  Future<Map<String, dynamic>> getQuestsSummary() async {
    final snap = await _questsSummaryRef.get();
    return snap.data() ?? <String, dynamic>{};
  }

  Future<void> updateBrowse() async {
    await ensureWeek();
    await _questsSummaryRef.update({'browseCount': FieldValue.increment(1)});
  }

  Future<void> updatePost() async {
    await ensureWeek();
    await _questsSummaryRef.update({'postCount': FieldValue.increment(1)});
  }

  Future<void> updatePurchase(int amountTk) async {
    await ensureWeek();
    await _questsSummaryRef
        .update({'purchaseTk': FieldValue.increment(amountTk)});
  }

  Future<void> updateRating() async {
    await ensureWeek();
    await _questsSummaryRef.update({'ratingCount': FieldValue.increment(1)});
  }

  Future<List<String>> claimEligibleQuests() async {
    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final granted = <String>[];

    await _db.runTransaction((txn) async {
      final qsSnap = await txn.get(_questsSummaryRef);
      final data = qsSnap.data() ?? <String, dynamic>{};

      // Lift each field to a local, then type-check.
      final completedRaw = data['completed'];
      final List<String> completed =
          (completedRaw is List) ? List<String>.from(completedRaw) : <String>[];

      final browseRaw = data['browseCount'];
      final int browse = (browseRaw is num) ? browseRaw.toInt() : 0;

      final postRaw = data['postCount'];
      final int post = (postRaw is num) ? postRaw.toInt() : 0;

      final purchaseRaw = data['purchaseTk'];
      final int purchaseTk = (purchaseRaw is num) ? purchaseRaw.toInt() : 0;

      final ratingRaw = data['ratingCount'];
      final int rating = (ratingRaw is num) ? ratingRaw.toInt() : 0;

      final questDefs = <String, Map<String, int>>{
        'browse5': {'ok': browse >= 5 ? 1 : 0, 'pts': 20, 'tix': 1},
        'post1': {'ok': post >= 1 ? 1 : 0, 'pts': 30, 'tix': 1},
        'purchase300': {'ok': purchaseTk >= 300 ? 1 : 0, 'pts': 40, 'tix': 1},
        'rate1': {'ok': rating >= 1 ? 1 : 0, 'pts': 10, 'tix': 0},
      };

      int totalPoints = 0;
      int totalTickets = 0;

      for (final id in questDefs.keys) {
        final ok = questDefs[id]!['ok'] == 1;
        if (ok && !completed.contains(id)) {
          completed.add(id);
          totalPoints += questDefs[id]!['pts']!;
          totalTickets += questDefs[id]!['tix']!;
          granted.add(id);
        }
      }

      if (granted.isEmpty) return;

      txn.set(
        _rewardsSummaryRef,
        {
          'totalPoints': FieldValue.increment(totalPoints),
          'lifetimePoints': FieldValue.increment(totalPoints),
        },
        SetOptions(merge: true),
      );

      txn.set(
        _gamesSummaryRef,
        {'tickets': FieldValue.increment(totalTickets)},
        SetOptions(merge: true),
      );

      txn.set(_rewardTransactionsRef.doc(), {
        'type': 'quest',
        'points': totalPoints,
        'createdAt': Timestamp.now(),
        'meta': {
          'granted': granted,
          'weekStartAt': Timestamp.fromDate(weekStart),
        },
      });

      txn.update(_questsSummaryRef, {'completed': completed});
    });

    return granted;
  }
}
