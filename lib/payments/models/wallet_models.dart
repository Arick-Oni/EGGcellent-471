import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod { bkash, nagad, card, wallet }

// We’ll use `payOrder` going forward.
// Older docs that used "orderPayment" will still parse (see helper below).
enum MoneyTxType { addMoney, payOrder }

MoneyTxType _moneyTxTypeFromString(String s) {
  switch (s) {
    case 'addMoney':
      return MoneyTxType.addMoney;
    case 'payOrder':
    case 'orderPayment': // <-- backward compatibility for existing data
      return MoneyTxType.payOrder;
    default:
      return MoneyTxType.addMoney; // safe fallback
  }
}

class WalletSummary {
  final int balance; // tk
  const WalletSummary({required this.balance});
  static const empty = WalletSummary(balance: 0);

  factory WalletSummary.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return WalletSummary(balance: (d['balance'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toMap() => {'balance': balance};
}

class MoneyTransaction {
  final String id;
  final MoneyTxType type;
  final int amount; // + add money, - order payment
  final PaymentMethod method;
  final DateTime createdAt;
  final String? orderId;
  final int? pointsUsed;

  MoneyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.method,
    required this.createdAt,
    this.orderId,
    this.pointsUsed,
  });

  factory MoneyTransaction.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MoneyTransaction(
      id: doc.id,
      type: _moneyTxTypeFromString((d['type'] ?? '').toString()),
      amount: (d['amount'] as num).toInt(),
      method: PaymentMethod.values.firstWhere((e) => e.name == d['method'],
          orElse: () => PaymentMethod.wallet),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      orderId: d['orderId'] as String?,
      pointsUsed: (d['pointsUsed'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name, // writes "payOrder" for order payments
        'amount': amount,
        'method': method.name,
        'createdAt': Timestamp.fromDate(createdAt),
        if (orderId != null) 'orderId': orderId,
        if (pointsUsed != null) 'pointsUsed': pointsUsed,
      };
}

class OrderItem {
  final String name;
  final int qty;
  final int unitPrice;
  OrderItem({required this.name, required this.qty, required this.unitPrice});
  int get lineTotal => qty * unitPrice;

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        name: m['name'],
        qty: (m['qty'] as num).toInt(),
        unitPrice: (m['unitPrice'] as num).toInt(),
      );
}

class OrderRecord {
  final String id;
  final List<OrderItem> items;
  final int total;
  final int pointsUsed;
  final int amountPaid;
  final String paymentOption; // 'points' | 'wallet' | 'points+wallet'
  final DateTime createdAt;

  OrderRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.pointsUsed,
    required this.amountPaid,
    required this.paymentOption,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'pointsUsed': pointsUsed,
        'amountPaid': amountPaid,
        'paymentOption': paymentOption,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory OrderRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return OrderRecord(
      id: doc.id,
      items: (d['items'] as List)
          .cast<Map>()
          .map((m) => OrderItem.fromMap(m.cast()))
          .toList(),
      total: (d['total'] as num).toInt(),
      pointsUsed: (d['pointsUsed'] as num).toInt(),
      amountPaid: (d['amountPaid'] as num).toInt(),
      paymentOption: d['paymentOption'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}
