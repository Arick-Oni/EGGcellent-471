import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/order/orderdetails.dart';

class Trackorder extends StatefulWidget {
  const Trackorder({super.key});

  @override
  State<Trackorder> createState() => _TrackorderState();
}

class _TrackorderState extends State<Trackorder> {
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
            .where('userId', isEqualTo: userId)
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
              final data = orders[index].data() as Map<String, dynamic>;
              final type = data['type'] ?? 'Unknown';
              final kg = data['kg'] ?? '';
              final address = data['address'] ?? '';
              dynamic orderDateRaw = data['orderDate'];
              final status = data['status'] ?? 'Pending';
              DateTime? orderDate;
              if (orderDateRaw is Timestamp) {
                orderDate = orderDateRaw.toDate();
              } else if (orderDateRaw is String) {
                // Try to parse ISO8601 or common formats
                try {
                  orderDate = DateTime.parse(orderDateRaw);
                } catch (_) {
                  orderDate = null;
                }
              } else {
                orderDate = null;
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
                      builder: (_) => OrderDetailsPage(
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
