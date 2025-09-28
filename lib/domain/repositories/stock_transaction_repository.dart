import 'package:inventory_management_app/domain/entities/stock_transaction.dart';

abstract class StockTransactionRepository {
  Stream<List<StockTransaction>> watchTransactionsForProduct(String productId);
  Stream<List<StockTransaction>> watchRecentTransactions({int limit = 5});
  Future<void> addTransaction(StockTransaction transaction);
}