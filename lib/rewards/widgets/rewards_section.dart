// lib/rewards/widgets/rewards_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardsSection extends StatelessWidget {
  const RewardsSection({super.key});

  // ---------- Firestore helpers ----------
  DocumentReference<Map<String, dynamic>> _summaryRef(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('rewardsSummary')
          .doc('summary');

  CollectionReference<Map<String, dynamic>> _rewardTxRef(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('rewardTransactions');

  Stream<DocumentSnapshot<Map<String, dynamic>>> _summaryStream(String uid) =>
      _summaryRef(uid).snapshots();

  // ---------- UI helpers ----------
  Future<int?> _askPointsToRedeem(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redeem points'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Points',
            hintText: 'e.g. 50',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  /// Deduct [points] from rewardsSummary and create a negative rewardTransaction.
  /// Returns the discount (1 point = 1 tk).
  Future<int> _redeemPoints(String uid, int points) async {
    final db = FirebaseFirestore.instance;
    final sumRef = _summaryRef(uid);
    final txDoc = _rewardTxRef(uid).doc();
    final now = DateTime.now();

    await db.runTransaction((txn) async {
      final snap = await txn.get(sumRef);
      final current = (snap.data()?['totalPoints'] as num?)?.toInt() ?? 0;

      if (points <= 0) throw StateError('Enter a value greater than 0');
      if (current < points) throw StateError('Not enough points ($current)');

      txn.set(
        sumRef,
        {'totalPoints': FieldValue.increment(-points)},
        SetOptions(merge: true),
      );

      txn.set(txDoc, {
        'type': 'redeem',
        'points': -points,
        'createdAt': Timestamp.fromDate(now),
        'meta': {'note': 'manual redeem via RewardsSection'},
      });
    });

    return points; // 1:1
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _summaryStream(uid),
          builder: (context, snap) {
            final map = snap.data?.data() ?? <String, dynamic>{};
            final pts = (map['totalPoints'] as num?)?.toInt() ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rewards',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Your points: $pts'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/wallet'),
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('Add Money'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final p = await _askPointsToRedeem(context);
                        if (p == null || p <= 0) return;

                        try {
                          final discount = await _redeemPoints(uid, p);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Redeemed $p pts → discount $discount৳'),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Redeem failed: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.redeem_outlined),
                      label: const Text('Redeem'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/transactions'),
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/spin'),
                      icon: const Icon(Icons.casino),
                      label: const Text('Spin'),
                    ),
                    // NEW: Scratch Cards
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/scratch'),
                      icon: const Icon(Icons.style),
                      label: const Text('Scratch Cards'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Orders',
                    onPressed: () => Navigator.pushNamed(context, '/orders'),
                    icon: const Icon(Icons.receipt_long),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
