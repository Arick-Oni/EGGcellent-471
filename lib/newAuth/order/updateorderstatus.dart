import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Updateorderstatus extends StatefulWidget {
  final String orderId;
  final String type;
  final String kg;
  final String address;
  final DateTime? orderDate;
  final String status;

  const Updateorderstatus({
    super.key,
    required this.orderId,
    required this.type,
    required this.kg,
    required this.address,
    this.orderDate,
    required this.status,
  });

  @override
  State<Updateorderstatus> createState() => _UpdateorderstatusState();
}

class _UpdateorderstatusState extends State<Updateorderstatus> {
  late String _currentStatus;

  final List<String> _statusOptions = [
    "In Company",
    "On the way",
    "Delivered",
    "Pending",
    "Cancelled",
    "Returned",
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  Future<void> _updateStatusInFirestore(String newStatus) async {
    if (widget.orderId.isEmpty) {
      print('Error: Order ID is missing or invalid: ${widget.orderId}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Order ID is missing or invalid.")),
      );
      return;
    }

    try {
      final docRef =
          FirebaseFirestore.instance.collection("orders").doc(widget.orderId);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        print("Error: Document with orderId ${widget.orderId} not found.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Order not found.")),
        );

        // Optional: Create the document if it doesn't exist
        // await docRef.set({"status": newStatus}, SetOptions(merge: true));
        return;
      }

      await docRef.update({"status": newStatus});

      setState(() {
        _currentStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to '$newStatus'")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _currentStatus == "Delivered"
        ? Colors.green
        : (_currentStatus == "On the way" ? Colors.orange : Colors.blue);

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.shopping_bag, "Type", widget.type),
                const SizedBox(height: 15),
                _infoRow(Icons.scale, "Weight", "${widget.kg} kg"),
                const SizedBox(height: 15),
                _infoRow(Icons.location_on, "Address", widget.address),
                const SizedBox(height: 15),
                _infoRow(
                  Icons.date_range,
                  "Order Date",
                  widget.orderDate != null
                      ? widget.orderDate!.toLocal().toString().split(' ')[0]
                      : 'N/A',
                ),
                const SizedBox(height: 25),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Status: $_currentStatus",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Update Status Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      String? selected = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: const Text("Select New Status"),
                            children: _statusOptions.map((status) {
                              return SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, status),
                                child: Text(status),
                              );
                            }).toList(),
                          );
                        },
                      );

                      if (selected != null && selected != _currentStatus) {
                        _updateStatusInFirestore(selected);
                      }
                    },
                    child: const Text(
                      "Update Status",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
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
