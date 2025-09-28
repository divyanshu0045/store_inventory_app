import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/stock_transaction_repository_impl.dart';
import 'package:inventory_management_app/domain/entities/stock_transaction.dart';
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';
import 'package:inventory_management_app/domain/usecases/add_stock_transaction.dart';
import 'package:inventory_management_app/domain/usecases/watch_stock_transactions_for_product.dart';

// 1. Repository Provider
final stockTransactionRepositoryProvider =
    Provider<StockTransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StockTransactionRepositoryImpl(db);
});

// 2. Use Case Providers
final addStockTransactionProvider = Provider<AddStockTransaction>((ref) {
  final repository = ref.watch(stockTransactionRepositoryProvider);
  return AddStockTransaction(repository);
});

final watchStockTransactionsForProductProvider =
    Provider<WatchStockTransactionsForProduct>((ref) {
  final repository = ref.watch(stockTransactionRepositoryProvider);
  return WatchStockTransactionsForProduct(repository);
});

// 3. StreamProvider.family for the transaction list
final transactionListStreamProvider = StreamProvider.autoDispose
    .family<List<StockTransaction>, String>((ref, productId) {
  final watchTransactions =
      ref.watch(watchStockTransactionsForProductProvider);
  return watchTransactions(productId);
});