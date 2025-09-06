import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardEvent {
  dailyLogin,
  listingCreated,
  saleCompleted,
  purchaseCompleted,
  interaction,
  redeem,
  topupBonus, // for add-money bonus
}

class RewardTransaction {
  final String id;
  final RewardEvent type;
  final int points; // + earn, - redeem
  final DateTime createdAt;
  final Map<String, dynamic>? meta;

  RewardTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.createdAt,
    this.meta,
  });

  factory RewardTransaction.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return RewardTransaction(
      id: doc.id,
      type: _eventFromString(d['type'] as String),
      points: (d['points'] as num).toInt(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      meta: (d['meta'] as Map?)?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'points': points,
        'createdAt': Timestamp.fromDate(createdAt),
        if (meta != null) 'meta': meta,
      };

  static RewardEvent _eventFromString(String s) => RewardEvent.values
      .firstWhere((e) => e.name == s, orElse: () => RewardEvent.interaction);
}

class UserPoints {
  final int totalPoints;
  final int lifetimePoints;
  final DateTime? lastDailyLoginDate;
  final DateTime? lastInteractionAt;

  const UserPoints({
    required this.totalPoints,
    required this.lifetimePoints,
    this.lastDailyLoginDate,
    this.lastInteractionAt,
  });

  static const empty = UserPoints(totalPoints: 0, lifetimePoints: 0);

  factory UserPoints.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserPoints(
      totalPoints: (d['totalPoints'] as num?)?.toInt() ?? 0,
      lifetimePoints: (d['lifetimePoints'] as num?)?.toInt() ?? 0,
      lastDailyLoginDate: (d['lastDailyLoginDate'] as Timestamp?)?.toDate(),
      lastInteractionAt: (d['lastInteractionAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'totalPoints': totalPoints,
        'lifetimePoints': lifetimePoints,
        if (lastDailyLoginDate != null)
          'lastDailyLoginDate': Timestamp.fromDate(lastDailyLoginDate!),
        if (lastInteractionAt != null)
          'lastInteractionAt': Timestamp.fromDate(lastInteractionAt!),
      };
}
