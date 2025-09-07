import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final Stream<QuerySnapshot<Map<String, dynamic>>> perUserStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> topLevelStream =
        FirebaseFirestore.instance
            .collection('orders')
            .where('buyerId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots();

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary.withOpacity(0.25),
                Colors.amber.withOpacity(0.25)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1115), Color(0xFF12151C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: perUserStream,
          builder: (context, perUserSnap) {
            if (perUserSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (perUserSnap.hasData && perUserSnap.data!.docs.isNotEmpty) {
              return _buildList(context, perUserSnap.data!.docs);
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: topLevelStream,
              builder: (context, topSnap) {
                if (topSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!topSnap.hasData || topSnap.data!.docs.isEmpty) {
                  return const _EmptyOrders();
                }
                return _buildList(context, topSnap.data!.docs);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final d = docs[i].data();

        final title =
            (d['title'] ?? d['name'] ?? d['itemTitle'] ?? 'Item').toString();
        final qty = (d['qty'] as num?)?.toInt() ??
            (d['quantity'] as num?)?.toInt() ??
            0;
        final unit = (d['unitPriceTk'] as num?)?.toInt() ??
            (d['pricePerUnit'] as num?)?.toInt() ??
            (d['price'] as num?)?.toInt() ??
            0;

        final totalTk = (d['totalTk'] as num?)?.toInt() ??
            (d['total'] as num?)?.toInt() ??
            qty * unit;

        final payment = (d['payment'] as Map?)?.cast<String, dynamic>();
        final pointsUsed = (d['pointsUsed'] as num?)?.toInt() ??
            (payment?['pointsUsed'] as num?)?.toInt() ??
            0;
        final amountPaid = (d['amountPaid'] as num?)?.toInt() ??
            (payment?['walletDebited'] as num?)?.toInt() ??
            0;

        final paymentOption = (d['paymentOption'] ??
                (pointsUsed > 0 && amountPaid > 0
                    ? 'points+wallet'
                    : (pointsUsed > 0 ? 'points' : 'wallet')))
            .toString();

        final status = (d['status'] ?? '').toString();
        final createdAt = (d['createdAt'] is Timestamp)
            ? (d['createdAt'] as Timestamp).toDate()
            : null;

        final scheme = Theme.of(context).colorScheme;

        Color statusColor(String s) {
          final ss = s.toLowerCase();
          if (ss.contains('delivered') || ss.contains('completed'))
            return Colors.greenAccent;
          if (ss.contains('shipped') || ss.contains('processing'))
            return Colors.amberAccent;
          if (ss.contains('cancel')) return Colors.redAccent;
          return Colors.blueGrey.shade200;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withOpacity(0.85),
                    scheme.primary.withOpacity(0.55)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.receipt_long_rounded, color: Colors.black87),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.amberAccent.withOpacity(0.45)),
                  ),
                  child: Text(
                    '${totalTk}tk',
                    style: const TextStyle(
                        color: Colors.amberAccent, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip(
                          icon: Icons.format_list_numbered_rounded,
                          label: 'Qty: $qty'),
                      _chip(icon: Icons.sell_outlined, label: '@ $unit tk'),
                      _chip(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Paid: ${amountPaid}tk',
                        color: Colors.greenAccent.withOpacity(0.15),
                        textColor: Colors.greenAccent,
                      ),
                      _chip(
                        icon: Icons.star_border_rounded,
                        label: 'Points: $pointsUsed',
                        color: Colors.lightBlueAccent.withOpacity(0.15),
                        textColor: Colors.lightBlueAccent,
                      ),
                      _chip(
                          icon: Icons.payments_outlined, label: paymentOption),
                      if (status.isNotEmpty)
                        _chip(
                          icon: Icons.local_shipping_outlined,
                          label: status,
                          color: statusColor(status).withOpacity(0.15),
                          textColor: statusColor(status),
                        ),
                    ],
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 14, color: Colors.white60),
                        const SizedBox(width: 6),
                        Text(
                          createdAt.toLocal().toString(),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    Color? color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: (textColor ?? Colors.white54).withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.white54),
          SizedBox(height: 10),
          Text('No orders yet.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
