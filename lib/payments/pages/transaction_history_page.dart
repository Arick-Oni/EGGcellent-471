import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:poultry_app/payments/data/firestore_wallet_repository.dart';
import 'package:poultry_app/payments/models/wallet_models.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final repo = FirestoreWalletRepository();
    final df = DateFormat('yyyy-MM-dd HH:mm');

    Color _amountColor(int amount) => amount >= 0
        ? Colors.greenAccent
        : Colors.redAccent; // gain/loss cue [2]
    IconData _typeIcon(MoneyTxType t) => t == MoneyTxType.addMoney
        ? Icons.account_balance_wallet_rounded
        : Icons.shopping_cart_rounded; // clear iconography [1]

    final bg = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F1115), Color(0xFF12151C)],
    ); // soft backdrop for contrast [3]

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Log'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.25),
                Theme.of(context).colorScheme.primary.withOpacity(0.25)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: bg),
        child: StreamBuilder<List<MoneyTransaction>>(
          stream: repo.watchTransactions(uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // smooth loading affordance [3]
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const _EmptyState(); // clean empty state [3]
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = items[i];
                final isGain = t.amount >= 0;
                final sign = isGain ? '+' : '';
                final color = _amountColor(t.amount);
                final subtitleParts = <String>[
                  df.format(t.createdAt),
                  'Method: ${t.method.name}',
                  if (t.orderId != null) 'Order: ${t.orderId}',
                  if (t.pointsUsed != null) 'Points used: ${t.pointsUsed}',
                ]; // compact metadata chips base [2]

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
                  ), // card-style tile per Material list guidance [1][3]
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            (isGain ? Colors.greenAccent : Colors.redAccent)
                                .withOpacity(0.85),
                            (isGain ? Colors.greenAccent : Colors.redAccent)
                                .withOpacity(0.55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(_typeIcon(t.type),
                          color: Colors.black87), // immediate type cue [1]
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.type.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.45)),
                          ),
                          child: Text(
                            '$sign${t.amount} tk',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ), // right-aligned amount badge per chip best practices [2]
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _chip(Icons.schedule, df.format(t.createdAt)),
                          _chip(Icons.credit_card, 'Method: ${t.method.name}'),
                          if (t.orderId != null)
                            _chip(Icons.receipt_long_rounded,
                                'Order: ${t.orderId}'),
                          if (t.pointsUsed != null)
                            _chip(Icons.star_border_rounded,
                                'Points used: ${t.pointsUsed}'),
                        ],
                      ),
                    ), // readable chips instead of dense paragraph text [2][1]
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    ); // compact chip pattern improves scanability in lists [2]
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.white54),
          SizedBox(height: 10),
          Text('No transactions yet', style: TextStyle(color: Colors.white70)),
        ],
      ),
    ); // friendly empty state per Material guidance [3]
  }
}
