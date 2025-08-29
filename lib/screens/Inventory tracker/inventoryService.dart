import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerInventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize farmer inventory with 0 quantity for all products
  Future<void> initializeFarmerInventory(String farmerId) async {
    try {
      final docRef = _firestore.collection("farmer_inventory").doc(farmerId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({
          "Broiler": 0,
          "Deshi": 0,
          "Eggs": 0,
          "Hatching Eggs": 0,
          "Chicks": 0,
          "Ducks": 0,
        });
        print(" Inventory initialized for farmer $farmerId");
      } else {
        print("Inventory already exists for farmer $farmerId");
      }
    } catch (e) {
      print("Error initializing farmer inventory: $e");
    }
  }

  /// Increase product quantity when farmer posts new stock
  Future<void> addProduct(String farmerId, String productType, int quantity) async {
    try {
      final docRef = _firestore.collection("farmer_inventory").doc(farmerId);

      await docRef.update({
        productType: FieldValue.increment(quantity),
      });

      print("Added $quantity $productType for farmer $farmerId");
    } catch (e) {
      print("Error adding product: $e");
    }
  }

  /// Decrease product quantity when buyer purchases
  Future<void> reduceProduct(String farmerId, String productType, int quantity) async {
    try {
      final docRef = _firestore.collection("farmer_inventory").doc(farmerId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Farmer inventory does not exist for $farmerId");
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentQuantity = data[productType] ?? 0;

        if (currentQuantity < quantity) {
          throw Exception("Not enough stock for $productType. Available: $currentQuantity, Needed: $quantity");
        }

        // Update inventory
        transaction.update(docRef, {
          productType: currentQuantity - quantity,
        });
      });

      print("✅ Reduced $quantity $productType for farmer $farmerId");
    } catch (e) {
      print("❌ Error reducing product: $e");
    }
  }

  /// Get farmer inventory snapshot (real-time updates)
  Stream<DocumentSnapshot> getFarmerInventory(String farmerId) {
    return _firestore.collection("farmer_inventory").doc(farmerId).snapshots();
  }
}
