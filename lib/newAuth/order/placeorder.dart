import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/orders/pages/place_order_page.dart';

class OrderNow extends StatelessWidget {
  final String orderId;
  final String title;
  final String farmerId;
  final int? unitPriceTk; // Add unit price parameter

  const OrderNow({
    super.key,
    required this.orderId,
    required this.title,
    required this.farmerId,
    this.unitPriceTk, // Optional for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    Future<void> submitOrder() async {
      try {
        // Fetch the ad data to get the unit price
        final adDoc = await FirebaseFirestore.instance
            .collection('collectionofall')
            .doc(orderId)
            .get();

        int unitPrice = unitPriceTk ?? 100; // Default fallback

        if (adDoc.exists) {
          final data = adDoc.data();
          if (data != null && data.containsKey('price')) {
            unitPrice = (data['price'] as num?)?.toInt() ?? unitPrice;
          }
        }

        // Navigate to the new PlaceOrderPage with the fetched price
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceOrderPage(
              itemId: orderId,
              title: title,
              sellerId: farmerId,
              unitPriceTk: unitPrice,
            ),
          ),
        );
      } catch (e) {
        // If price fetch fails, use default price
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceOrderPage(
              itemId: orderId,
              title: title,
              sellerId: farmerId,
              unitPriceTk: unitPriceTk ?? 100,
            ),
          ),
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
          constraints:
              BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
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
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Product: $title'),
                          Text('Seller ID: $farmerId'),
                          if (unitPriceTk != null)
                            Text('Unit Price: ৳$unitPriceTk'),
                          const SizedBox(height: 8),
                          Text(
                            'Click "Submit Order" to proceed with quantity and delivery details.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding:
                          EdgeInsets.symmetric(vertical: isDesktop ? 20 : 16),
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
