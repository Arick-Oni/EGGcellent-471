import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poultry_app/rewards/data/firestore_rewards_repository.dart';
import 'package:poultry_app/rewards/models/reward_models.dart';

class RewardsHistoryPage extends StatelessWidget {
  const RewardsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final repo = FirestoreRewardsRepository();
    final df = DateFormat('yyyy-MM-dd HH:mm');

    String human(RewardEvent e) {
      switch (e) {
        case RewardEvent.dailyLogin:
          return 'Daily Login';
        case RewardEvent.listingCreated:
          return 'Listing Created';
        case RewardEvent.saleCompleted:
          return 'Sale Completed';
        case RewardEvent.purchaseCompleted:
          return 'Purchase Completed';
        case RewardEvent.interaction:
          return 'Interaction';
        case RewardEvent.redeem:
          return 'Redeemed';
        case RewardEvent.topupBonus:
          return 'Top-up Bonus';
      }
    }

    Color _typeColor(RewardEvent e, bool isGain) {
      if (!isGain) return Colors.redAccent;
      switch (e) {
        case RewardEvent.dailyLogin:
          return Colors.lightGreenAccent;
        case RewardEvent.listingCreated:
          return Colors.amberAccent;
        case RewardEvent.saleCompleted:
          return Colors.greenAccent;
        case RewardEvent.purchaseCompleted:
          return Colors.tealAccent;
        case RewardEvent.interaction:
          return Colors.blueAccent.shade100;
        case RewardEvent.topupBonus:
          return Colors.purpleAccent;
        case RewardEvent.redeem:
          return Colors.redAccent;
      }
    }

    IconData _typeIcon(RewardEvent e, bool isGain) {
      if (!isGain) return Icons.redeem_rounded;
      switch (e) {
        case RewardEvent.dailyLogin:
          return Icons.login_rounded;
        case RewardEvent.listingCreated:
          return Icons.post_add_rounded;
        case RewardEvent.saleCompleted:
          return Icons.sell_rounded;
        case RewardEvent.purchaseCompleted:
          return Icons.shopping_bag_rounded;
        case RewardEvent.interaction:
          return Icons.favorite_border_rounded;
        case RewardEvent.topupBonus:
          return Icons.bolt_rounded;
        case RewardEvent.redeem:
          return Icons.redeem_rounded;
      }
    }

    Widget _empty(BuildContext ctx) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.white54),
            SizedBox(height: 10),
            Text('No transactions yet',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    final bg = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F1115), Color(0xFF12151C)],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward History'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.25),
                Theme.of(context).colorScheme.primary.withOpacity(0.25),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: bg),
        child: StreamBuilder<List<RewardTransaction>>(
          stream: repo.watchTransactions(uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? [];
            if (items.isEmpty) return _empty(context);

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = items[i];
                final isGain = t.points >= 0;
                final sign = isGain ? '+' : '';
                final color = _typeColor(t.type, isGain);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.85),
                            color.withOpacity(0.55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(_typeIcon(t.type, isGain),
                          color: Colors.black87),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            human(t.type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isGain
                                ? Colors.greenAccent.withOpacity(0.15)
                                : Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isGain
                                  ? Colors.greenAccent.withOpacity(0.5)
                                  : Colors.redAccent.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            '$sign${t.points} pts',
                            style: TextStyle(
                              color: isGain
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Colors.white60),
                          const SizedBox(width: 6),
                          Text(df.format(t.createdAt),
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
