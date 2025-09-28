import 'package:inventory_management_app/domain/entities/stock_transaction.dart';
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';

class WatchRecentTransactions {
  final StockTransactionRepository repository;

  WatchRecentTransactions(this.repository);

  Stream<List<StockTransaction>> call({int limit = 5}) {
    return repository.watchRecentTransactions(limit: limit);
  }
}