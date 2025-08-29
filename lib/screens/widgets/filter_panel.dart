// TODO Implement this library.
import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onSortChanged;

  const FilterPanel({
    super.key,
    required this.onTypeChanged,
    required this.onCityChanged,
    required this.onRegionChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize
            .min, // Added: Prevents the Row from expanding unnecessarily
        children: [
          DropdownButton<String>(
            // Change: Removed Expanded
            hint: const Text("Product Type"),
            items: ["broiler", "layer", "eggs", "deshi"]
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => onTypeChanged(value ?? ''),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextField(
              decoration: InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: onCityChanged,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextField(
              decoration: InputDecoration(
                labelText: "Region",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: onRegionChanged,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            // Change: Removed Expanded
            hint: const Text("Sort by"),
            items: const [
              DropdownMenuItem(value: "price", child: Text("Price")),
              DropdownMenuItem(
                value: "rating",
                child: Text("Seller Rating"),
              ),
              DropdownMenuItem(
                value: "activity",
                child: Text("Seller Activity"),
              ),
            ],
            onChanged: (value) => onSortChanged(value ?? ''),
          ),
        ],
      ),
    );
  }
}
