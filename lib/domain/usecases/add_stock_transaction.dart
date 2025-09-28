import 'package:inventory_management_app/domain/entities/stock_transaction.dart';
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';

class AddStockTransaction {
  final StockTransactionRepository repository;

  AddStockTransaction(this.repository);

  Future<void> call(StockTransaction transaction) {
    return repository.addTransaction(transaction);
  }
}