import 'package:inventory_management_app/core/errors/failures.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/entities/stock_transaction.dart' as domain;
import 'package:inventory_management_app/domain/repositories/stock_transaction_repository.dart';

class StockTransactionRepositoryImpl implements StockTransactionRepository {
  final db.AppDatabase _database;

  StockTransactionRepositoryImpl(this._database);

  @override
  Stream<List<domain.StockTransaction>> watchTransactionsForProduct(
      String productId) {
    return _database.stockTransactionDao
        .watchTransactionsForProduct(productId)
        .map((transactions) => transactions
            .map((t) => _mapDbTransactionToDomainTransaction(t))
            .toList());
  }

  @override
  Future<void> addTransaction(domain.StockTransaction transaction) {
    return _database.transaction(() async {
      // 1. Insert the transaction record
      await _database.stockTransactionDao
          .insertTransaction(_mapDomainTransactionToDbTransaction(transaction));

      // 2. Get the current product
      final product = await _database.productDao.getProductById(transaction.productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      // 3. Calculate the new stock quantity
      final newQuantity = _calculateNewQuantity(
          product.stockQuantity, transaction.quantity, transaction.type);

      // 4. Update the product with the new quantity
      await _database.productDao.updateProduct(product.copyWith(stockQuantity: newQuantity));
    });
  }

  int _calculateNewQuantity(int currentQty, int changeQty, db.TransactionType type) {
    switch (type) {
      case db.TransactionType.IN:
        return currentQty + changeQty;
      case db.TransactionType.OUT:
      case db.TransactionType.ADJUST:
        final newQty = currentQty - changeQty;
        if (newQty < 0) {
          throw InsufficientStockException(
              'Cannot complete transaction. Stock would be negative.');
        }
        return newQty;
    }
  }

  domain.StockTransaction _mapDbTransactionToDomainTransaction(
      db.StockTransaction transaction) {
    return domain.StockTransaction(
      id: transaction.id,
      productId: transaction.productId,
      type: db.TransactionType.values[transaction.type],
      quantity: transaction.quantity,
      timestamp: transaction.timestamp,
      reason: transaction.reason,
    );
  }

  db.StockTransaction _mapDomainTransactionToDbTransaction(
      domain.StockTransaction transaction) {
    return db.StockTransaction(
      id: transaction.id,
      productId: transaction.productId,
      type: transaction.type.index,
      quantity: transaction.quantity,
      timestamp: transaction.timestamp,
      reason: transaction.reason,
    );
  }
}