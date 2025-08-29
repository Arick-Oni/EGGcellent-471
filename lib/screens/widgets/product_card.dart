// TODO Implement this library.
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Change: Added elevation for shadow/depth
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ), // Change: Added margins
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ), // Change: Rounded corners
      child: ListTile(
        leading: const Icon(
          Icons.egg,
          color: Colors.amber,
          size: 40,
        ), // Change: Added icon for aesthetics (egg/chicken theme)
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ), // Change: Bold title
        ),
        subtitle: Text(
          "${product.city}, ${product.region}\n"
          "Type: ${product.type} | "
          "Price: \$${product.price.toStringAsFixed(2)}\n"
          "Rating: ${product.sellerRating} | Activity: ${product.sellerActivity}",
          style: TextStyle(
            color: Colors.grey[700],
          ), // Change: Subtle color for subtitle
        ),
      ),
    );
  }
}
