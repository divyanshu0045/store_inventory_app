import 'package:inventory_management_app/domain/entities/stock_transaction.dart';
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';

class WatchStockTransactionsForProduct {
  final StockTransactionRepository repository;

  WatchStockTransactionsForProduct(this.repository);

  Stream<List<StockTransaction>> call(String productId) {
    return repository.watchTransactionsForProduct(productId);
  }
}