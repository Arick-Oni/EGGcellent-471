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

  // Tunables
  static const int bonusThresholdTk = 500; // top-up bonus trigger
  static const int bonusPoints = 100; // pts when top-up >= threshold
  static const int pointToTk = 1; // 1 pt = 1 tk
  static const List<int> _streakLadder = [5, 8, 12, 16, 20, 20, 20];

  // Bonus on every 3rd paid order of the day
  static const int bonusPer3Orders = 5;

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
      final int currentBal =
          wSnap.exists ? (wSnap.data()?['balance'] as num?)?.toInt() ?? 0 : 0;

      txn.set(
        walletRef,
        {'balance': currentBal + amountTk},
        SetOptions(merge: true),
      );

      txn.set(walletTxDoc, {
        'type': MoneyTxType.addMoney.name,
        'amount': amountTk,
        'method': method.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      // 🎟️ 1 ticket per 200 tk
      final int tickets = amountTk ~/ 200;
      if (tickets > 0) {
        txn.set(
          gamesSummaryRef,
          {'tickets': FieldValue.increment(tickets)},
          SetOptions(merge: true),
        );
      }
    });

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
        SetOptions(merge: true),
      );
      batch.set(rewardTxRef, {
        'type': RewardEvent.topupBonus.name,
        'points': bonusPoints,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'meta': {'amountTk': amountTk, 'method': method.name},
      });
      await batch.commit();
    }
  }

  // ---- REPLACEMENT payForOrder method STARTS HERE ----

  Future<void> payForOrder({
    required String orderId,
    required int totalTk,
    bool usePointsFirst = true,
  }) async {
    final buyerUid = uid;
    final _db = FirebaseFirestore.instance;

    final buyerRef = _db.collection('users').doc(buyerUid);
    final buyerRewardsSummaryRef =
        buyerRef.collection('rewardsSummary').doc('summary');
    final buyerWalletRef = buyerRef.collection('wallet').doc('summary');
    final buyerWalletTxRef = buyerRef.collection('transactions').doc();
    final buyerOrderRef = buyerRef.collection('orders').doc(orderId);

    final orderRef = _db.collection('orders').doc(orderId);
    final now = DateTime.now();

    final odSnap = await orderRef.get();
    final Map odData = (odSnap.data() as Map?) ?? {};

    final int qty = (odData['qty'] as num?)?.toInt() ?? 1;
    final int unit = (odData['unitPriceTk'] as num?)?.toInt() ?? 0;
    final DateTime createdAt =
        (odData['createdAt'] as Timestamp?)?.toDate() ?? now;
    final String? sellerId = odData['sellerId']?.toString();

    if (sellerId == null) throw Exception('Order does not contain sellerId');
    if (sellerId == buyerUid)
      throw Exception('Buyer and seller cannot be the same.');

    final farmerRef = _db.collection('users').doc(sellerId);
    final farmerWalletRef = farmerRef.collection('wallet').doc('summary');
    final farmerWalletTxRef = farmerRef.collection('transactions').doc();
    final farmerOrderRef = farmerRef.collection('orders').doc(orderId);

    // Leaderboard and rewards for buyer only
    final gamesSummaryRef = buyerRef.collection('gamesSummary').doc('summary');
    final leaderboardRef =
        _db.collection('leaderboard').doc(buyerUid); // global

    // today’s daily doc for leaderboard
    final dayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final dailyRef = _db
        .collection('leaderboardDaily')
        .doc(dayKey)
        .collection('users')
        .doc(buyerUid);

    await _db.runTransaction((txn) async {
      // ---- BUYER READS ----
      final buyerRewardsSnap = await txn.get(buyerRewardsSummaryRef);
      final buyerWalletSnap = await txn.get(buyerWalletRef);
      final daySnap = await txn.get(dailyRef);

      final int currentPoints =
          (buyerRewardsSnap.data()?['totalPoints'] as num?)?.toInt() ?? 0;
      final int currentBal =
          (buyerWalletSnap.data()?['balance'] as num?)?.toInt() ?? 0;

      final Map? dayMap = daySnap.data();
      final int prevOrders = (dayMap?['ordersCount'] as num?)?.toInt() ?? 0;
      final int newOrders = prevOrders + 1;
      final bool hitMilestone = newOrders % 3 == 0;

      // ---- BUYER COMPUTE ----
      final int pointsToUse = usePointsFirst
          ? (currentPoints < totalTk ? currentPoints : totalTk)
          : 0;
      final int remaining = totalTk - pointsToUse;

      if (remaining > currentBal) {
        throw Exception('Insufficient wallet balance for this payment.');
      }

      int purchasePoints = 0;
      if (qty >= 6) {
        purchasePoints = 10;
      } else if (qty >= 3) {
        purchasePoints = 5;
      }
      final int extraBonus = hitMilestone ? bonusPer3Orders : 0;
      final DateTime paidAt = now;
      final String paymentOption = pointsToUse > 0 && remaining > 0
          ? 'points+wallet'
          : (pointsToUse > 0 ? 'points' : 'wallet');

      // ---- BUYER WRITES ----
      if (pointsToUse > 0) {
        txn.set(
          buyerRewardsSummaryRef,
          {'totalPoints': FieldValue.increment(-pointsToUse)},
          SetOptions(merge: true),
        );
        final rewardTxRef = buyerRef.collection('rewardTransactions').doc();
        txn.set(rewardTxRef, {
          'type': RewardEvent.redeem.name,
          'points': -pointsToUse,
          'createdAt': Timestamp.fromDate(paidAt),
          'meta': {'orderId': orderId},
        });
      }

      if (remaining > 0) {
        txn.set(
          buyerWalletRef,
          {'balance': FieldValue.increment(-remaining)},
          SetOptions(merge: true),
        );
        txn.set(buyerWalletTxRef, {
          'type': MoneyTxType.payOrder.name,
          'amount': -remaining,
          'method': 'wallet',
          'createdAt': Timestamp.fromDate(paidAt),
          'orderId': orderId,
          'pointsUsed': pointsToUse,
        });
      }

      txn.set(
        orderRef,
        {
          'status': 'paid',
          'payment': {
            'pointsUsed': pointsToUse,
            'walletDebited': remaining,
            'paidAt': Timestamp.fromDate(paidAt),
          },
          'updatedAt': Timestamp.fromDate(paidAt),
          'buyerId': buyerUid,
        },
        SetOptions(merge: true),
      );

      txn.set(
        buyerOrderRef,
        {
          'orderId': orderId,
          'title': odData['title'] ?? 'Item',
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
        SetOptions(merge: true),
      );

      // Buyer rewards and leaderboard
      if (purchasePoints > 0) {
        txn.set(
          buyerRewardsSummaryRef,
          {
            'totalPoints': FieldValue.increment(purchasePoints),
            'lifetimePoints': FieldValue.increment(purchasePoints),
          },
          SetOptions(merge: true),
        );
        final earnTx = buyerRef.collection('rewardTransactions').doc();
        txn.set(earnTx, {
          'type': RewardEvent.purchaseCompleted.name,
          'points': purchasePoints,
          'createdAt': Timestamp.fromDate(paidAt),
          'meta': {'orderId': orderId, 'qty': qty},
        });
      }

      txn.set(
        gamesSummaryRef,
        {'tickets': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      if (totalTk >= 300) {
        final scratchRef = buyerRef.collection('scratchCards').doc();
        txn.set(scratchRef, {
          'used': false,
          'prize': null,
          'createdAt': Timestamp.fromDate(paidAt),
          'orderId': orderId,
        });
      }

      // Global leaderboard
      txn.set(
        leaderboardRef,
        {
          'uid': buyerUid,
          'displayName': FirebaseAuth.instance.currentUser?.displayName ??
              FirebaseAuth.instance.currentUser?.email ??
              'User',
          'photoUrl': FirebaseAuth.instance.currentUser?.photoURL,
          'pointsEarned': FieldValue.increment(purchasePoints),
          'itemsPurchased': FieldValue.increment(qty),
          'updatedAt': Timestamp.fromDate(paidAt),
        },
        SetOptions(merge: true),
      );

      // Daily leaderboard (+ milestone bonus)
      txn.set(
        dailyRef,
        {
          'uid': buyerUid,
          'displayName': FirebaseAuth.instance.currentUser?.displayName ??
              FirebaseAuth.instance.currentUser?.email ??
              'User',
          'photoUrl': FirebaseAuth.instance.currentUser?.photoURL,
          'ordersCount': FieldValue.increment(1),
          'itemsPurchased': FieldValue.increment(qty),
          'pointsEarned': FieldValue.increment(purchasePoints + extraBonus),
          'lastOrderAt': Timestamp.fromDate(paidAt),
        },
        SetOptions(merge: true),
      );

      if (extraBonus > 0) {
        txn.set(
          buyerRewardsSummaryRef,
          {
            'totalPoints': FieldValue.increment(extraBonus),
            'lifetimePoints': FieldValue.increment(extraBonus),
          },
          SetOptions(merge: true),
        );
        final bonusTx = buyerRef.collection('rewardTransactions').doc();
        txn.set(bonusTx, {
          'type': 'daily3xBonus',
          'points': extraBonus,
          'createdAt': Timestamp.fromDate(paidAt),
          'meta': {'ordersToday': newOrders, 'day': dayKey},
        });
      }

      // ---- FARMER CREDIT ----
      txn.set(
        farmerWalletRef,
        {'balance': FieldValue.increment(totalTk)},
        SetOptions(merge: true),
      );
      txn.set(farmerWalletTxRef, {
        'type': MoneyTxType.addMoney.name,
        'amount': totalTk,
        'method': 'wallet',
        'createdAt': Timestamp.fromDate(paidAt),
        'orderId': orderId,
        'fromBuyer': buyerUid,
      });
      txn.set(
        farmerOrderRef,
        {
          'orderId': orderId,
          'title': odData['title'] ?? 'Item',
          'qty': qty,
          'unitPriceTk': unit,
          'totalTk': totalTk,
          'status': 'sold',
          'createdAt': Timestamp.fromDate(createdAt),
          'soldAt': Timestamp.fromDate(paidAt),
          'buyerId': buyerUid,
        },
        SetOptions(merge: true),
      );
      // (No rewards and no leaderboard for farmer)
    });
  }

  /// Daily login award with soft streak drop.
  Future<void> awardDailyLoginIfEligible() async {
    final userRef = _db.collection('users').doc(uid);
    final sumRef = userRef.collection('rewardsSummary').doc('summary');
    final txRef = userRef.collection('rewardTransactions').doc();

    await _db.runTransaction((txn) async {
      final snap = await txn.get(sumRef);

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

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
        final diff = today.difference(lastLogin!).inDays;
        if (diff == 0) {
          return; // already awarded today
        } else if (diff == 1) {
          streak += 1;
        } else {
          streak = (streak ~/ 2).clamp(1, 9999);
        }
      } else {
        streak = 1;
      }

      final int idx = (streak - 1).clamp(0, _streakLadder.length - 1);
      final int points = _streakLadder[idx];

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
