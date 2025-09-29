import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';

// 1. StateProvider for the global search query
final globalSearchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

// 2. StreamProvider for product search results
// This provider watches the global search query and calls the repository directly.
final productSearchResultsProvider =
    StreamProvider.autoDispose<List<db.Product>>((ref) {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProducts(searchQuery: query);
});

// 3. StreamProvider for supplier search results
// This provider also watches the global search query and calls its repository directly.
final supplierSearchResultsProvider =
    StreamProvider.autoDispose<List<db.Supplier>>((ref) {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.watchSuppliers(searchQuery: query);
});