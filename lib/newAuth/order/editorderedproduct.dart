import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/order/updateorderstatus.dart';

class Editorderedproduct extends StatefulWidget {
  const Editorderedproduct({super.key});

  @override
  State<Editorderedproduct> createState() => _EditorderedproductState();
}

class _EditorderedproductState extends State<Editorderedproduct> {
  String? userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Track Order")),
        body: const Center(child: Text("Please login first")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('farmerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final type = data['type'] ?? 'Unknown';
              final kg = data['kg'] ?? '';
              final address = data['address'] ?? '';
              final status = data['status'] ?? 'Pending';

              // Parse order date
              dynamic orderDateRaw = data['orderDate'];
              DateTime? orderDate;
              if (orderDateRaw is Timestamp) {
                orderDate = orderDateRaw.toDate();
              } else if (orderDateRaw is String) {
                try {
                  orderDate = DateTime.parse(orderDateRaw);
                } catch (_) {
                  orderDate = null;
                }
              }

              return ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                title: Text("$type - ${kg}kg"),
                subtitle: Text(
                  "Delivery to: $address\n${orderDate != null ? orderDate.toLocal().toString().split(' ')[0] : ''}",
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Updateorderstatus(
                        orderId: doc.id, 
                        status: status,
                        type: type,
                        kg: kg,
                        address: address,
                        orderDate: orderDate,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
