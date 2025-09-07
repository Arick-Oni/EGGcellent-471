import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_app/payments/services/wallet_service.dart';
import 'package:poultry_app/payments/models/wallet_models.dart';
import 'package:poultry_app/payments/data/firestore_wallet_repository.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _amountCtrl = TextEditingController();
  PaymentMethod _method = PaymentMethod.bkash;
  final _service = WalletService();
  final _repo = FirestoreWalletRepository();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1115), Color(0xFF12151C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ), // soft backdrop for contrast and elegance [1]
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.35)),
                  ),
                  child: const Text(
                    'You are not signed in. Please log in to use the wallet.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ), // clear, styled status message [1]

              if (user != null)
                StreamBuilder<WalletSummary>(
                  stream: _repo.watchWallet(user.uid),
                  builder: (context, snapshot) {
                    final bal = snapshot.data?.balance ?? 0;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
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
                            child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.black87),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Available Balance',
                                style: TextStyle(color: Colors.white70)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.amberAccent.withOpacity(0.45)),
                            ),
                            child: Text(
                              '${bal} tk',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ); // glossy balance card with badge [4][1]
                  },
                ),

              const SizedBox(height: 18),
              Text('Add money', style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 10),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (tk)',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.12)),
                  ),
                  prefixIcon: const Icon(Icons.currency_exchange_rounded),
                ),
              ), // tasteful field styling per Material inputs [1]

              const SizedBox(height: 14),
              Text('Payment method',
                  style: Theme.of(context).textTheme.titleSmall),

              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _pmChip(
                    context: context,
                    label: 'Bkash',
                    icon: Icons.account_balance,
                    selected: _method == PaymentMethod.bkash,
                    onTap: () => setState(() => _method = PaymentMethod.bkash),
                  ),
                  _pmChip(
                    context: context,
                    label: 'Nagad',
                    icon: Icons.account_balance_wallet_rounded,
                    selected: _method == PaymentMethod.nagad,
                    onTap: () => setState(() => _method = PaymentMethod.nagad),
                  ),
                  _pmChip(
                    context: context,
                    label: 'Card',
                    icon: Icons.credit_card_rounded,
                    selected: _method == PaymentMethod.card,
                    onTap: () => setState(() => _method = PaymentMethod.card),
                  ),
                ],
              ), // branded method chips improve scanability [5][1]

              const Spacer(),

              // CTA
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade600,
                        Colors.deepOrange.shade400
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // show gradient
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ), // large, accessible primary action per Material buttons [3][2]
                    onPressed: () async {
                      if (FirebaseAuth.instance.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please sign in first.')),
                        );
                        return;
                      }

                      final amt = int.tryParse(_amountCtrl.text.trim()) ?? 0;
                      if (amt <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid amount')),
                        );
                        return;
                      }

                      try {
                        await _service.addMoney(amountTk: amt, method: _method);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Added ${amt}tk. Bonus points if ≥ 500 tk.')),
                        );
                        _amountCtrl.clear();
                      } on FirebaseException catch (e, st) {
                        debugPrint('FIREBASE EX: ${e.code}  ${e.message}\n$st');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Firestore: ${e.code} — ${e.message ?? 'Unknown error'}')),
                        );
                      } catch (e, st) {
                        debugPrint('UNKNOWN EX: $e\n$st');
                        String msg = e.toString();
                        try {
                          final dyn = e as dynamic;
                          final code = dyn.code ?? dyn.error?.code;
                          final m = dyn.message ?? dyn.error?.message;
                          if (m != null)
                            msg = (code != null) ? '$code — $m' : '$m';
                        } catch (_) {}
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $msg')));
                      }
                    },
                    child: const Text('Add Money'),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/transactions'),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('See Transactions'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/orders'),
                      icon: const Icon(Icons.local_mall_rounded),
                      label: const Text('See Orders'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pmChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final selColor = selected ? Colors.amberAccent : Colors.white70;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.amberAccent.withOpacity(0.15)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? Colors.amberAccent.withOpacity(0.55)
                  : Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selColor),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(color: selColor, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ); // custom chip for clear selection and brand feel [5][1]
  }
}
