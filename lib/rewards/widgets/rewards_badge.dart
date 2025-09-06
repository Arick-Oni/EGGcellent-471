import 'package:flutter/material.dart';
import 'package:poultry_app/rewards/data/firestore_rewards_repository.dart';
import 'package:poultry_app/rewards/models/reward_models.dart';

class RewardsBadge extends StatelessWidget {
  final String uid;
  const RewardsBadge({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final repo = FirestoreRewardsRepository();
    return StreamBuilder<UserPoints>(
      stream: repo.watchSummary(uid),
      builder: (context, snap) {
        final points = snap.data?.totalPoints ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade700,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text('$points pts',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
