import 'package:poultry_app/rewards/models/reward_models.dart';

abstract class RewardsRepository {
  Stream<UserPoints> watchSummary(String uid);
  Stream<List<RewardTransaction>> watchTransactions(String uid);
  Future<UserPoints> getSummaryOnce(String uid);

  Future<void> addEarnTransaction({
    required String uid,
    required RewardEvent event,
    required int points,
    Map<String, dynamic>? meta,
  });

  Future<void> redeem({
    required String uid,
    required int points,
    Map<String, dynamic>? meta,
  });
}
