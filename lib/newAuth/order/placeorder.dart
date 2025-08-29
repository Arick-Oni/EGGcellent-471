import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/order/ordermodel.dart';
import '../../screens/Inventory tracker/inventoryService.dart';

class OrderNow extends StatelessWidget {
  final String orderId;
  final String title;
  final String farmerId;

  const OrderNow({
    super.key,
    required this.orderId,
    required this.title,
    required this.farmerId,
  });

  @override
  Widget build(BuildContext context) {
    final quantityController = TextEditingController();
    final addressController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser?.uid ?? '';
    final inventoryService = FarmerInventoryService();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    Future<void> submitOrder() async {
      if (quantityController.text.isEmpty || addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      final int orderedQuantity = int.tryParse(quantityController.text) ?? 0;
      if (orderedQuantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid quantity')),
        );
        return;
      }

      try {
        final farmerInventoryDoc = await FirebaseFirestore.instance
            .collection('farmer_inventory')
            .doc(farmerId)
            .get();

        if (!farmerInventoryDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Farmer inventory not found')),
          );
          return;
        }

        final dynamic farmerQtyRaw = farmerInventoryDoc.data()?[title] ?? 0;
        final int availableQuantity = farmerQtyRaw is int
            ? farmerQtyRaw
            : int.tryParse(farmerQtyRaw.toString()) ?? 0;

        if (orderedQuantity > availableQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Ordered quantity exceeds available stock. Available: $availableQuantity'),
            ),
          );
          return;
        }

        final order = OrderModel(
          farmerId: farmerId,
          type: title,
          userId: user,
          kg: orderedQuantity.toString(),
          address: addressController.text,
          status: 'Pending',
          orderId: orderId,
        );

        await FirebaseFirestore.instance.collection('orders').add(order.toMap());
        await inventoryService.reduceProduct(farmerId, title, orderedQuantity);

        final adDocRef =
        FirebaseFirestore.instance.collection('collectionofall').doc(orderId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(adDocRef);
          if (!snapshot.exists) throw Exception("Ad not found");

          final dynamic adQtyRaw = snapshot.data()?['quantity'] ?? 0;
          final int currentAdQuantity = adQtyRaw is int
              ? adQtyRaw
              : int.tryParse(adQtyRaw.toString()) ?? 0;

          if (orderedQuantity > currentAdQuantity) {
            throw Exception(
                "Ordered quantity ($orderedQuantity) exceeds available ad quantity ($currentAdQuantity)");
          }

          transaction.update(adDocRef, {'quantity': currentAdQuantity - orderedQuantity});
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order submitted successfully!')),
        );

        Navigator.pop(context);
        quantityController.clear();
        addressController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 20 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'SUBMIT ORDER',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
