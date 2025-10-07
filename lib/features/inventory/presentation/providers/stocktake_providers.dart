import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';

enum StocktakeFilterType { full, location, category }

@immutable
class StocktakeFilter {
  final StocktakeFilterType type;
  final String? value;

  const StocktakeFilter({required this.type, this.value});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StocktakeFilter &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}

/// Provider to fetch a distinct list of all product locations.
final stocktakeLocationsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getAllLocations();
});

/// Provider to fetch a distinct list of all product categories.
final stocktakeCategoriesProvider = FutureProvider.autoDispose<List<String>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getAllCategories();
});

/// Provider to fetch the list of products for a given stocktake filter.
final stocktakeProductsProvider =
    FutureProvider.autoDispose.family<List<db.Product>, StocktakeFilter>((ref, filter) {
  final productRepository = ref.watch(productRepositoryProvider);
  // This will require a new method in the repository.
  // For now, we'll assume it exists and implement it next.
  return productRepository.getProductsForStocktake(filter);
});