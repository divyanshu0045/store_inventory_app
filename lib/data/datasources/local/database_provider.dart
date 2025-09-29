import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final productDaoProvider = Provider<ProductDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.productDao;
});

final supplierDaoProvider = Provider<SupplierDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.supplierDao;
});

final userDaoProvider = Provider<UserDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.userDao;
});

final stockTransactionDaoProvider = Provider<StockTransactionDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.stockTransactionDao;
});