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
        // Handle error state
        if (snap.hasError) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, size: 18, color: Colors.red),
                SizedBox(width: 6),
                Text('Error', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        // Handle loading state only for initial connection
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade700.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                  ),
                ),
                SizedBox(width: 6),
                Text('0 pts',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    )),
              ],
            ),
          );
        }

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
