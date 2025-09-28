import 'package:inventory_management_app/data/datasources/local/database.dart'
    show TransactionType;

class StockTransaction {
  final String id;
  final String productId;
  final TransactionType type;
  final int quantity;
  final DateTime timestamp;
  final String? reason;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.timestamp,
    this.reason,
  });
}