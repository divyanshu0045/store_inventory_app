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
      final product = await _database.productDao.getProductById(transaction.productId);
      if (product == null) {
        throw Exception('Product not found for stock transaction.');
      }

      // If a lot is specified, adjust that lot directly.
      if (transaction.lotId != null) {
        await _adjustSpecificLot(transaction);
      }
      // If no lot is specified (e.g., from a stocktake adjustment), adjust the first available lot.
      else if (transaction.type == db.TransactionType.ADJUST) {
        await _adjustFirstAvailableLot(transaction);
      } else {
        throw Exception('IN/OUT transactions must be associated with a specific lot.');
      }

      // Insert the transaction record AFTER processing the logic.
      await _database.stockTransactionDao.insertTransaction(transaction);

      // Recalculate the product's total stock quantity by summing all its lots.
      final allLots = await (_database.select(_database.lots)..where((l) => l.productId.equals(transaction.productId))).get();
      final totalStock = allLots.fold<int>(0, (sum, currentLot) => sum + currentLot.quantity);

      // Update the product's main stock quantity.
      await _database.productDao.updateProduct(product.copyWith(stockQuantity: totalStock));
    });
  }

  Future<void> _adjustSpecificLot(db.StockTransaction transaction) async {
    final lot = await (_database.select(_database.lots)..where((l) => l.id.equals(transaction.lotId!))).getSingleOrNull();
    if (lot == null) throw Exception('Lot not found for stock transaction.');

    int newLotQuantity;
    if (transaction.type == db.TransactionType.IN) {
      newLotQuantity = lot.quantity + transaction.quantity;
    } else { // OUT or ADJUST
      newLotQuantity = lot.quantity - transaction.quantity;
      if (newLotQuantity < 0) {
        throw InsufficientStockException('Insufficient stock in batch ${lot.batchNumber}. Required: ${transaction.quantity}, available: ${lot.quantity}.');
      }
    }

    await (_database.update(_database.lots)..where((l) => l.id.equals(transaction.lotId!)))
        .write(db.LotsCompanion(quantity: Value(newLotQuantity)));
  }

  Future<void> _adjustFirstAvailableLot(db.StockTransaction transaction) async {
      final lots = await (_database.select(_database.lots)..where((l) => l.productId.equals(transaction.productId))).get();
      if (lots.isEmpty) {
        throw Exception('Cannot adjust stock for a product with no lots. Please add a lot first.');
      }
      // Simple strategy: adjust the first lot. A more complex strategy (e.g., FEFO) could be used here.
      final lotToAdjust = lots.first;
      final newQuantity = lotToAdjust.quantity + transaction.quantity; // ADJUST quantity can be negative

       if (newQuantity < 0) {
          throw InsufficientStockException('Insufficient stock in batch ${lotToAdjust.batchNumber}. Adjustment would result in negative quantity.');
        }

      await (_database.update(_database.lots)..where((l) => l.id.equals(lotToAdjust.id)))
          .write(db.LotsCompanion(quantity: Value(newQuantity)));
  }
}