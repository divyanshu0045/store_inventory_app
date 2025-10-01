import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';

// 1. FutureProvider for the total product count.
// This provider directly calls the repository method.
final productCountProvider = FutureProvider.autoDispose<int>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductCount();
});

// 2. FutureProvider for the count of low-stock items.
// This provider directly calls the repository method.
final lowStockCountProvider = FutureProvider.autoDispose<int>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getLowStockCount();
});

// 3. StreamProvider for the list of low-stock products.
final lowStockProductsProvider = StreamProvider.autoDispose<List<db.Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  // Call the existing repository method with the lowStock flag.
  return repository.watchProducts(lowStock: true);
});

// 4. FutureProvider for the list of top-stocked products.
final topStockedProductsProvider = FutureProvider.autoDispose<List<db.Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getTopStockedProducts();
});