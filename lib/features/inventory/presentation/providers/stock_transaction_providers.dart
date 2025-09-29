import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/stock_transaction_repository_impl.dart';
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';

// 1. Repository Provider
// Exposes the repository implementation via its abstract interface.
final stockTransactionRepositoryProvider =
    Provider<StockTransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return StockTransactionRepositoryImpl(database);
});

// 2. StreamProvider for the transaction list for a specific product
// The `.family` modifier allows passing the productId to fetch the correct stream.
final transactionListStreamProvider = StreamProvider.autoDispose
    .family<List<db.StockTransaction>, String>((ref, productId) {
  final repository = ref.watch(stockTransactionRepositoryProvider);
  return repository.watchTransactionsForProduct(productId);
});

// 3. StreamProvider for recent transactions (e.g., for a dashboard)
final recentTransactionsStreamProvider =
    StreamProvider.autoDispose<List<db.StockTransaction>>((ref) {
  final repository = ref.watch(stockTransactionRepositoryProvider);
  // You can adjust the limit as needed.
  return repository.watchRecentTransactions(limit: 10);
});