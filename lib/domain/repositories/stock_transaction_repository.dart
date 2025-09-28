import 'package:inventory_management_app/domain/entities/stock_transaction.dart';

abstract class StockTransactionRepository {
  Stream<List<StockTransaction>> watchTransactionsForProduct(String productId);
  Future<void> addTransaction(StockTransaction transaction);
}