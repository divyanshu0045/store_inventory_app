import 'package:drift/drift.dart';
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
      // 1. Get the product to ensure it exists.
      final product = await _database.productDao.getProductById(transaction.productId);
      if (product == null) {
        throw Exception('Product not found for stock transaction.');
      }

      // 2. If the transaction is linked to a specific lot, update the lot's quantity.
      if (transaction.lotId != null) {
        final lot = await (_database.select(_database.lots)..where((l) => l.id.equals(transaction.lotId!))).getSingleOrNull();
        if (lot == null) {
          throw Exception('Lot not found for stock transaction.');
        }

        int newLotQuantity;
        if (transaction.type == db.TransactionType.IN) {
          newLotQuantity = lot.quantity + transaction.quantity;
        } else { // OUT or ADJUST
          newLotQuantity = lot.quantity - transaction.quantity;
          if (newLotQuantity < 0) {
            throw InsufficientStockException('Insufficient stock in batch ${lot.batchNumber}. Required: ${transaction.quantity}, available: ${lot.quantity}.');
          }
        }

        // Update the specific lot's quantity.
        await (_database.update(_database.lots)..where((l) => l.id.equals(transaction.lotId!)))
            .write(db.LotsCompanion(quantity: Value(newLotQuantity)));
      }

      // 3. Insert the transaction record.
      await _database.stockTransactionDao.insertTransaction(transaction);

      // 4. Recalculate the product's total stock quantity by summing all its lots.
      final allLots = await (_database.select(_database.lots)..where((l) => l.productId.equals(transaction.productId))).get();
      final totalStock = allLots.fold<int>(0, (sum, currentLot) => sum + currentLot.quantity);

      // 5. Update the product's main stock quantity with the new total.
      await _database.productDao.updateProduct(product.copyWith(stockQuantity: totalStock));
    });
  }
}