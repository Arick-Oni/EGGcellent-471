import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_app/orders/services/order_service.dart';
import 'package:poultry_app/payments/pages/payment_sheet.dart';

class PlaceOrderPage extends StatefulWidget {
  final String itemId;
  final String title;
  final String sellerId;
  final int unitPriceTk;

  const PlaceOrderPage({
    super.key,
    required this.itemId,
    required this.title,
    required this.sellerId,
    required this.unitPriceTk,
  });

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final _qtyCtrl = TextEditingController(text: '1');
  final _addrCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity (units/kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addrCtrl,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: user == null
                  ? null
                  : () async {
                      final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
                      final addr = _addrCtrl.text.trim();
                      if (qty <= 0 || addr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Enter a valid qty and address.')),
                        );
                        return;
                      }
                      try {
                        final ref = await OrderService().createOrder(
                          itemId: widget.itemId,
                          title: widget.title,
                          sellerId: widget.sellerId,
                          quantity: qty,
                          unitPriceTk: widget.unitPriceTk,
                          deliveryAddress: addr,
                        );

                        final totalTk = qty * widget.unitPriceTk;
                        if (!mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentSheet(
                                  orderId: ref.id, totalTk: totalTk),
                            ));
                      } on Exception catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed: $e')));
                      }
                    },
              child: const Text('SUBMIT ORDER'),
            ),
          ],
        ),
      ),
    );
  }
}
