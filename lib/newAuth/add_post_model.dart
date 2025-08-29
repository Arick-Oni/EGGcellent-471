class AdModel {
  String id;
  String userId;
  String? imageUrl;
  String type;
  String name;
  int quantity;
  double price;
  String contactNumber;
  String city;
  String region;
  String description;
  DateTime createdAt;
  double? sellerRating;
  double? sellerActivity;

  AdModel({
    this.id = '',
    required this.userId,
    this.imageUrl,
    required this.type,
    required this.name,
    required this.quantity,
    required this.price,
    required this.contactNumber,
    required this.city,
    required this.region,
    required this.description,
    DateTime? createdAt,
    this.sellerRating,
    this.sellerActivity,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert model to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'type': type,
      'name': name,
      'quantity': quantity,
      'price': price,
      'contactNumber': contactNumber,
      'city': city,
      'region': region,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'sellerRating': sellerRating,
      'sellerActivity': sellerActivity,
    };
  }

  /// Create model from Firebase Map
  factory AdModel.fromMap(Map<String, dynamic> map, String docId) {
    double parseDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? defaultValue;
    }

    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return AdModel(
      id: docId,
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'],
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      quantity: parseInt(map['quantity']),
      price: parseDouble(map['price']),
      contactNumber: map['contactNumber'] ?? '',
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      sellerRating: parseDouble(map['sellerRating'], 4.5),
      sellerActivity: parseDouble(map['sellerActivity'], 10),
    );
  }
}
