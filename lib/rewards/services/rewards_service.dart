// lib/payments/services/wallet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:poultry_app/payments/models/wallet_models.dart';
import 'package:poultry_app/payments/data/firestore_wallet_repository.dart';
import 'package:poultry_app/rewards/models/reward_models.dart';

class WalletService {
  final _wallet = FirestoreWalletRepository();
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  static const int bonusThresholdTk = 500; // top-up bonus
  static const int bonusPoints = 100;
  static const int pointToTk = 1;

  // Daily-login streak ladder (points awarded for the day 1..7; capped at index 6).
  static const List<int> _streakLadder = [5, 8, 12, 16, 20, 20, 20];

  Stream<WalletSummary> watchWallet() => _wallet.watchWallet(uid);

  Future<void> addMoney({
    required int amountTk,
    required PaymentMethod method,
  }) async {
    final walletRef = _wallet.walletRef(uid);
    final walletTxDoc = _wallet.txRef(uid).doc();
    final gamesSummaryRef = _db
        .collection('users')
        .doc(uid)
        .collection('gamesSummary')
        .doc('summary');

    await _db.runTransaction((txn) async {
      final wSnap = await txn.get(walletRef);
      final currentBal =
          wSnap.exists ? (wSnap.data()!['balance'] as num?)?.toInt() ?? 0 : 0;

      txn.set(walletRef, {'balance': currentBal + amountTk},
          SetOptions(merge: true));
      txn.set(walletTxDoc, {
        'type': MoneyTxType.addMoney.name,
        'amount': amountTk,
        'method': method.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      // 🎟️ tickets: 1 per 200tk
      final tickets = amountTk ~/ 200;
      if (tickets > 0) {
        txn.set(gamesSummaryRef, {'tickets': FieldValue.increment(tickets)},
            SetOptions(merge: true));
      }
    });

    // bonus points for big top-up
    if (amountTk >= bonusThresholdTk) {
      final summaryRef = _db
          .collection('users')
          .doc(uid)
          .collection('rewardsSummary')
          .doc('summary');
      final rewardTxRef = _db
          .collection('users')
          .doc(uid)
          .collection('rewardTransactions')
          .doc();
      final batch = _db.batch();
      batch.set(
          summaryRef,
          {
            'totalPoints': FieldValue.increment(bonusPoints),
            'lifetimePoints': FieldValue.increment(bonusPoints),
          },
          SetOptions(merge: true));
      batch.set(rewardTxRef, {
        'type': RewardEvent.topupBonus.name,
        'points': bonusPoints,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'meta': {'amountTk': amountTk, 'method': method.name},
      });
      await batch.commit();
    }
  }

  /// Pay order: points-first then wallet; award purchase points; grant ticket; create scratch card if total≥300;
  /// update global 'leaderboard/{uid}'.
  Future<void> payForOrder({
    required String orderId,
    required int totalTk,
    bool usePointsFirst = true,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    final rewardsSummaryRef =
        userRef.collection('rewardsSummary').doc('summary');
    final walletRef = userRef.collection('wallet').doc('summary');
    final walletTxRef = userRef.collection('transactions').doc();

    final orderRef = _db.collection('orders').doc(orderId);
    final userOrderRef = userRef.collection('orders').doc(orderId);
    final leaderboardRef = _db.collection('leaderboard').doc(uid);
    final gamesSummaryRef = userRef.collection('gamesSummary').doc('summary');

    await _db.runTransaction((txn) async {
      final rw = await txn.get(rewardsSummaryRef);
      final wl = await txn.get(walletRef);
      final od = await txn.get(orderRef);
      if (!od.exists) throw StateError('Order not found');

      final odData = od.data() as Map<String, dynamic>;
      final title = (odData['title'] ?? 'Item').toString();
      final qty = (odData['qty'] as num?)?.toInt() ?? 0;
      final unit = (odData['unitPriceTk'] as num?)?.toInt() ?? 0;
      final createdAt =
          (odData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final sellerId = odData['sellerId'];

      final currentPoints = (rw.data()?['totalPoints'] as num?)?.toInt() ?? 0;
      final currentBal = (wl.data()?['balance'] as num?)?.toInt() ?? 0;

      final pointsToUse = usePointsFirst
          ? (currentPoints < totalTk ? currentPoints : totalTk)
          : 0;
      final remaining = totalTk - pointsToUse;
      if (remaining > currentBal) {
        throw StateError(
            'Insufficient wallet balance. Need ${remaining}tk more.');
      }

      // deduct points
      if (pointsToUse > 0) {
        txn.update(rewardsSummaryRef,
            {'totalPoints': FieldValue.increment(-pointsToUse)});
        final rewardTxRef = userRef.collection('rewardTransactions').doc();
        txn.set(rewardTxRef, {
          'type': RewardEvent.redeem.name,
          'points': -pointsToUse,
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'meta': {'orderId': orderId},
        });
      }

      // deduct wallet
      if (remaining > 0) {
        txn.update(walletRef, {'balance': FieldValue.increment(-remaining)});
        txn.set(walletTxRef, {
          'type': MoneyTxType.payOrder.name,
          'amount': -remaining,
          'method': 'wallet',
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'meta': {'orderId': orderId},
        });
      }

      final paidAt = DateTime.now();
      final paymentOption = pointsToUse > 0 && remaining > 0
          ? 'points+wallet'
          : (pointsToUse > 0 ? 'points' : 'wallet');

      // mark order paid (and remember buyerId)
      txn.update(orderRef, {
        'status': 'paid',
        'payment': {
          'pointsUsed': pointsToUse,
          'walletDebited': remaining,
          'paidAt': Timestamp.fromDate(paidAt),
        },
        'updatedAt': Timestamp.fromDate(paidAt),
        'buyerId': uid,
      });

      // per-user history
      txn.set(
          userOrderRef,
          {
            'orderId': orderId,
            'title': title,
            'qty': qty,
            'unitPriceTk': unit,
            'totalTk': totalTk,
            'pointsUsed': pointsToUse,
            'amountPaid': remaining,
            'paymentOption': paymentOption,
            'status': 'paid',
            'createdAt': Timestamp.fromDate(createdAt),
            'paidAt': Timestamp.fromDate(paidAt),
            'sellerId': sellerId,
          },
          SetOptions(merge: true));

      // purchase reward (qty thresholds)
      int purchasePoints = 0;
      if (qty >= 6) {
        purchasePoints = 10;
      } else if (qty >= 3) {
        purchasePoints = 5;
      }
      if (purchasePoints > 0) {
        txn.set(
            rewardsSummaryRef,
            {
              'totalPoints': FieldValue.increment(purchasePoints),
              'lifetimePoints': FieldValue.increment(purchasePoints),
            },
            SetOptions(merge: true));
        final earnTx = userRef.collection('rewardTransactions').doc();
        txn.set(earnTx, {
          'type': RewardEvent.purchaseCompleted.name,
          'points': purchasePoints,
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'meta': {'orderId': orderId, 'qty': qty},
        });
      }

      // 🎟️ +1 ticket for any paid order
      txn.set(gamesSummaryRef, {'tickets': FieldValue.increment(1)},
          SetOptions(merge: true));

      // 🎁 scratch card for orders >= 300 tk
      if (totalTk >= 300) {
        final scratchRef =
            userRef.collection('scratchCards').doc(); // used=false
        txn.set(scratchRef, {
          'used': false,
          'prize': null, // assigned when the user scratches
          'createdAt': Timestamp.fromDate(paidAt),
          'orderId': orderId,
        });
      }

      // Leaderboard aggregate
      txn.set(
          _db.collection('leaderboard').doc(uid),
          {
            'uid': uid,
            'displayName': FirebaseAuth.instance.currentUser?.displayName ??
                FirebaseAuth.instance.currentUser?.email ??
                'User',
            'photoUrl': FirebaseAuth.instance.currentUser?.photoURL,
            'pointsEarned': FieldValue.increment(purchasePoints),
            'itemsPurchased': FieldValue.increment(qty),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
          SetOptions(merge: true));
    });
  }

  /// Award daily login based on streak, soft-drop if missed days.
  Future<void> awardDailyLoginIfEligible() async {
    final userRef = _db.collection('users').doc(uid);
    final sumRef = userRef.collection('rewardsSummary').doc('summary');
    final txRef = userRef.collection('rewardTransactions').doc();

    await _db.runTransaction((txn) async {
      final snap = await txn.get(sumRef);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int streak = 0;
      DateTime? lastLogin;

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final sc = data['streakCount'];
        if (sc is num) streak = sc.toInt();
        final ts = data['lastDailyLoginDate'];
        if (ts is Timestamp) {
          final d = ts.toDate();
          lastLogin = DateTime(d.year, d.month, d.day);
        }
      }

      if (lastLogin != null) {
        final diff = today.difference(lastLogin).inDays;
        if (diff == 0) {
          // already awarded today
          return;
        } else if (diff == 1) {
          streak += 1;
        } else {
          // soft drop: keep half, at least 1
          streak = (streak ~/ 2).clamp(1, 9999);
        }
      } else {
        streak = 1;
      }

      final idx = (streak - 1).clamp(0, _streakLadder.length - 1);
      final points = _streakLadder[idx];

      txn.set(
        sumRef,
        {
          'totalPoints': FieldValue.increment(points),
          'lifetimePoints': FieldValue.increment(points),
          'streakCount': streak,
          'lastDailyLoginDate': Timestamp.fromDate(today),
        },
        SetOptions(merge: true),
      );

      txn.set(txRef, {
        'type': RewardEvent.dailyLogin.name,
        'points': points,
        'createdAt': Timestamp.now(),
        'meta': {'streak': streak},
      });
    });
  }
}
