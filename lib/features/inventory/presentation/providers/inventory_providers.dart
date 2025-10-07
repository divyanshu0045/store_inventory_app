import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/product_repository_impl.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_filter.dart';

// 1. Repository Provider (provides the abstraction)
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  // The implementation now only needs the local data source.
  final localDataSource = ref.watch(productDaoProvider);
  return ProductRepositoryImpl(localDataSource);
});

// 2. StateProvider for the product filter
// This holds the current filter state (search query and low stock toggle).
final productFilterProvider =
    StateProvider.autoDispose<ProductFilter>((ref) {
  return const ProductFilter(); // Initial default filter
});

// 3. StreamProvider for the filtered product list
// This provider watches the filter provider. When the filter changes,
// this provider re-runs and fetches a new stream from the repository.
final productListStreamProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  final filter = ref.watch(productFilterProvider);

  // Pass all available filter parameters to the repository.
  return productRepository.watchProducts(
    searchQuery: filter.searchQuery,
    lowStock: filter.lowStock,
    location: filter.location,
    category: filter.category,
    supplierId: filter.supplierId,
  );
});

// 4. FutureProvider.family for fetching a single product
final productDetailProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, id) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getProductById(id);
});

// 5. StreamProvider for products by a specific supplier
final productsBySupplierStreamProvider =
    StreamProvider.autoDispose.family<List<Product>, String>((ref, supplierId) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.watchProductsBySupplier(supplierId);
});