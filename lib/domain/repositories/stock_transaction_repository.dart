import 'package:inventory_management_app/data/datasources/local/database.dart' as db;

abstract class StockTransactionRepository {
  Stream<List<db.StockTransaction>> watchTransactionsForProduct(String productId);

  Stream<List<db.StockTransaction>> watchRecentTransactions({int limit = 10});

  Future<void> addTransaction(db.StockTransaction transaction);
}