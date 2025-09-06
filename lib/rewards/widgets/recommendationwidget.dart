import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A resilient recommendations grid that can read from:
///  - a top-level collection:  sourceCollection='ads', useCollectionGroup=false
///  - OR a collection group:   sourceCollection='myads', useCollectionGroup=true
///
/// It also shows real error messages (permission/index) instead of spinning forever.
class RecommendationWidget extends StatelessWidget {
  final String? category;
  final String sourceCollection;
  final bool useCollectionGroup;

  const RecommendationWidget({
    super.key,
    this.category,
    this.sourceCollection = 'ads', // change to what you actually store
    this.useCollectionGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> q = useCollectionGroup
        ? FirebaseFirestore.instance.collectionGroup(sourceCollection)
        : FirebaseFirestore.instance.collection(sourceCollection);

    if (category != null && category!.trim().isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }

    // If you store createdAt, this keeps newest first. Remove if you don’t have it.
    q = q.orderBy('createdAt', descending: true).limit(50);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading recommendations: ${snap.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No recommendations yet.'),
          );
        }

        final docs = snap.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data();

            final title = (d['title'] ?? d['name'] ?? 'Untitled').toString();
            final type = (d['type'] ?? d['category'] ?? 'N/A').toString();
            final qty = (d['qty'] ?? d['quantity'] ?? 'N/A').toString();
            final price = (d['pricePerUnit'] ?? d['price'] ?? 'N/A').toString();
            final location = (d['location'] ?? d['city'] ?? 'N/A').toString();
            final imageUrl = (d['imageUrl'] ?? d['photo'] ?? '').toString();

            return Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to a details page if you have one
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.black26,
                            child: const Center(
                                child: Icon(Icons.image_not_supported)),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 80,
                        color: Colors.black26,
                        child: const Center(child: Icon(Icons.pets)),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DefaultTextStyle(
                        style: const TextStyle(fontSize: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Type: $type'),
                            Text('Qty: $qty'),
                            Text('Price/unit: $price'),
                            Text(
                              'Location: $location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
