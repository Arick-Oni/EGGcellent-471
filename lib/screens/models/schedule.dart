class Schedule {
  final String id;
  final List<String> days;
  final bool enabled;
  final Map<String, dynamic>
      details; // Flexible for type-specific data (e.g., time, temp)

  Schedule({
    required this.id,
    required this.days,
    required this.enabled,
    required this.details,
  });

  factory Schedule.fromJson(String id, Map json) {
    final detailsRaw = json['details'] ?? {};
    final details = detailsRaw is Map<String, dynamic>
        ? detailsRaw
        : Map<String, dynamic>.from(detailsRaw as Map);

    return Schedule(
      id: id,
      days: List.from(json['days'] ?? []),
      enabled: json['enabled'] ?? true,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {'days': days, 'enabled': enabled, 'details': details};
  }
}
