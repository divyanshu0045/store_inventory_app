import 'package:inventory_management_app/core/errors/failures.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';

class StockTransactionRepositoryImpl implements StockTransactionRepository {
  final db.AppDatabase _database;

  StockTransactionRepositoryImpl(this._database);

  @override
  Stream<List<db.StockTransaction>> watchTransactionsForProduct(String productId) {
    return _database.stockTransactionDao.watchTransactionsForProduct(productId);
  }

  @override
  Stream<List<db.StockTransaction>> watchRecentTransactions({int limit = 10}) {
    return _database.stockTransactionDao.watchRecentTransactions(limit);
  }

  @override
  Future<void> addTransaction(db.StockTransaction transaction) {
    return _database.transaction(() async {
      // 1. Insert the transaction record
      await _database.stockTransactionDao.insertTransaction(transaction);

      // 2. Get the current product
      final product = await _database.productDao.getProductById(transaction.productId);
      if (product == null) {
        // In a real app, might want a more specific exception
        throw Exception('Product not found for stock transaction.');
      }

      // 3. Calculate the new stock quantity
      // The transaction.type is already a `TransactionType` enum due to the converter.
      final newQuantity = _calculateNewQuantity(
        product.stockQuantity,
        transaction.quantity,
        transaction.type,
      );

      // 4. Update the product with the new quantity
      await _database.productDao.updateProduct(product.copyWith(stockQuantity: newQuantity));
    });
  }

  int _calculateNewQuantity(int currentQty, int changeQty, db.TransactionType type) {
    switch (type) {
      case db.TransactionType.IN:
        return currentQty + changeQty;
      case db.TransactionType.OUT:
        // For OUT and ADJUST, we subtract from stock.
        final newQty = currentQty - changeQty;
        if (newQty < 0) {
          // This prevents stock from going negative.
          throw InsufficientStockException('Cannot complete transaction. Stock would be negative.');
        }
        return newQty;
      case db.TransactionType.ADJUST:
        // In this implementation, ADJUST is treated as an absolute new value, not a delta.
        // For a more robust system, you might handle ADJUST differently.
        // For now, we'll assume it behaves like an OUT for simplicity of quantity calculation logic.
        final adjustedQty = currentQty - changeQty;
         if (adjustedQty < 0) {
          throw InsufficientStockException('Cannot complete transaction. Stock would be negative.');
        }
        return adjustedQty;
    }
  }
}