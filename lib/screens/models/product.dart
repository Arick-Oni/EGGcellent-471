class Product {
  final String name;
  final double price;
  final String type; // "broiler" or "layer"
  final String city;
  final String region;
  final double sellerRating;
  final int sellerActivity;

  Product({
    required this.name,
    required this.price,
    required this.type,
    required this.city,
    required this.region,
    required this.sellerRating,
    required this.sellerActivity,
  });

  // Factory method to create Product from Firebase JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      region: json['region'] ?? 'Unknown',
      sellerRating: (json['sellerRating'] ?? 0.0).toDouble(),
      sellerActivity: json['sellerActivity'] ?? 0,
    );
  }

  // Convert Product to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'type': type,
      'city': city,
      'region': region,
      'sellerRating': sellerRating,
      'sellerActivity': sellerActivity,
    };
  }
}
