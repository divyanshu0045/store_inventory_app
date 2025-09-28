import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/product_repository_impl.dart';
import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/domain/usecases/add_product.dart';
import 'package:inventory_management_app/domain/usecases/delete_product.dart';
import 'package:inventory_management_app/domain/usecases/get_product_by_id.dart';
import 'package:inventory_management_app/domain/usecases/get_product_by_barcode.dart';
import 'package:inventory_management_app/domain/usecases/update_product.dart';
import 'package:inventory_management_app/domain/usecases/watch_products.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_filter.dart';

// 1. Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dao = ref.watch(productDaoProvider);
  return ProductRepositoryImpl(dao);
});

// 2. Use Case Provider
final watchProductsProvider = Provider<WatchProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return WatchProducts(repository);
});

// 3. StateProvider for the search query
final inventorySearchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

// 4. StateProvider for the inventory filter
final inventoryFilterProvider =
    StateProvider.autoDispose<InventoryFilter>((ref) {
  return InventoryFilter.all;
});

// 5. StreamProvider for the product list
final productListStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final watchProducts = ref.watch(watchProductsProvider);
  final searchQuery = ref.watch(inventorySearchQueryProvider);
  final filter = ref.watch(inventoryFilterProvider);

  return watchProducts(
    searchQuery: searchQuery,
    lowStock: filter == InventoryFilter.lowStock,
  );
});

// 4. Provider for the AddProduct use case
final addProductProvider = Provider<AddProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return AddProduct(repository);
});

// 5. Provider for the GetProductById use case
final getProductByIdProvider = Provider<GetProductById>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductById(repository);
});

// 6. FutureProvider.family for fetching a single product
final productDetailProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, id) {
  final getProductById = ref.watch(getProductByIdProvider);
  return getProductById(id);
});

// 7. Provider for the DeleteProduct use case
final deleteProductProvider = Provider<DeleteProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProduct(repository);
});

// 8. Provider for the UpdateProduct use case
final updateProductProvider = Provider<UpdateProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProduct(repository);
});

// 9. Provider for the GetProductByBarcode use case
final getProductByBarcodeProvider = Provider<GetProductByBarcode>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductByBarcode(repository);
});