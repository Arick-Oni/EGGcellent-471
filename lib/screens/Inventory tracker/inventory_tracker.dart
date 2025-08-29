import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InventoryTrackerPage extends StatelessWidget {
  const InventoryTrackerPage({super.key});

  final List<String> productTypes = const [
    "Broiler",
    "Deshi",
    "Eggs",
    "Hatching Eggs",
    "Chicks",
    "Ducks"
  ];

  @override
  Widget build(BuildContext context) {
    final String farmerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (farmerId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No farmer logged in",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final DocumentReference inventoryDoc =
    FirebaseFirestore.instance.collection("farmer_inventory").doc(farmerId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Inventory Tracker"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow,
        elevation: 2,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: inventoryDoc.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Inventory not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;

              if (isWide) {
                // Grid for web/tablet
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 1000 ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: productTypes.length,
                  itemBuilder: (context, index) {
                    final product = productTypes[index];
                    final dynamic qtyRaw = data[product] ?? 0;
                    final int quantity =
                    qtyRaw is int ? qtyRaw : int.tryParse(qtyRaw.toString()) ?? 0;

                    return Card(
                      color: Colors.grey[900],
                      shadowColor: Colors.yellow.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                // List for mobile
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: productTypes.length,
                  itemBuilder: (context, index) {
                    final product = productTypes[index];
                    final dynamic qtyRaw = data[product] ?? 0;
                    final int quantity =
                    qtyRaw is int ? qtyRaw : int.tryParse(qtyRaw.toString()) ?? 0;

                    return Card(
                      color: Colors.grey[900],
                      shadowColor: Colors.yellow.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          product,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        trailing: Text(
                          "$quantity",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
