import 'package:flutter/material.dart';
import '../../Responsive_helper.dart';

class OrderDetailsPage extends StatelessWidget {
  final String type;
  final String kg;
  final String address;
  final DateTime? orderDate;
  final String status;

  const OrderDetailsPage({
    super.key,
    required this.type,
    required this.kg,
    required this.address,
    this.orderDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == "Delivered"
        ? Colors.green
        : (status == "On the way" ? Colors.orange : Colors.blue);

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final horizontalPadding = isDesktop ? 200.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Card(
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          shadowColor: Colors.blueAccent,
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 30.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.shopping_bag, "Type", type, isDesktop),
                SizedBox(height: isDesktop ? 20 : 15),
                _infoRow(Icons.scale, "Weight", "$kg kg", isDesktop),
                SizedBox(height: isDesktop ? 20 : 15),
                _infoRow(Icons.location_on, "Address", address, isDesktop),
                SizedBox(height: isDesktop ? 20 : 15),
                _infoRow(
                  Icons.date_range,
                  "Order Date",
                  orderDate != null
                      ? orderDate!.toLocal().toString().split(' ')[0]
                      : 'N/A',
                  isDesktop,
                ),
                SizedBox(height: isDesktop ? 30 : 25),
                Divider(color: Colors.white54, thickness: 1),
                SizedBox(height: isDesktop ? 25 : 20),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : 16, vertical: isDesktop ? 12 : 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Status: $status",
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.cyanAccent, size: isDesktop ? 28 : 24),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$label: ",
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
