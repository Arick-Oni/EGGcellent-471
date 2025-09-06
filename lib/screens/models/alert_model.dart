class AlertModel {
  final String id;
  final String message;
  final int timestamp;
  final String alertName;

  AlertModel({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.alertName,
  });

  factory AlertModel.fromFirestore(
      Map<String, dynamic> data, String id, String alertName) {
    return AlertModel(
      id: id,
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? 0,
      alertName: alertName,
    );
  }

  bool isRecent() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (now - timestamp) <= 30; // Within last 30 seconds
  }
}
