import 'package:poultry_app/payments/models/wallet_models.dart';

abstract class WalletRepository {
  Stream<WalletSummary> watchWallet(String uid);
  Stream<List<MoneyTransaction>> watchTransactions(String uid);
  Stream<List<OrderRecord>> watchOrders(String uid);
  Future<WalletSummary> getWalletOnce(String uid);

  Future<void> addMoney({
    required String uid,
    required int amountTk,
    required PaymentMethod method,
  });

  Future<String> createOrderAndPay({
    required String uid,
    required List<OrderItem> items,
    required int pointsToUse,
  });
}
