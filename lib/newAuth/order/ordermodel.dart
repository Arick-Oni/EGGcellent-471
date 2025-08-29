class OrderModel {
  final String farmerId;
  final String status;
  final String type;
  final String userId;
  final String kg;
  final String address;
  final DateTime orderDate;
  String orderId;

  OrderModel({
    required this.farmerId,
    required this.status,
    required this.type,
    required this.userId,
    required this.kg,
    required this.address,
    DateTime? orderDate,
    required this.orderId,
  }) : orderDate = orderDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'status': status,
      'type': type,
      'userId': userId,
      'kg': kg,
      'address': address,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return OrderModel(
      farmerId: map['farmerId'] ?? '',
      status: map['status'] ?? 'Pending',
      type: map['type'] ?? '',
      userId: map['userId'] ?? '',
      kg: map['kg']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      orderDate: map['orderDate'] != null
          ? DateTime.tryParse(map['orderDate'])
          : DateTime.now(),
      orderId: id ?? '',
    );
  }
}
