import 'package:flutter/foundation.dart';

@immutable
class ProductFilter {
  final String? searchQuery;
  final bool lowStock;

  const ProductFilter({
    this.searchQuery,
    this.lowStock = false,
  });

  ProductFilter copyWith({
    String? searchQuery,
    bool? lowStock,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      lowStock: lowStock ?? this.lowStock,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductFilter &&
        other.searchQuery == searchQuery &&
        other.lowStock == lowStock;
  }

  @override
  int get hashCode => searchQuery.hashCode ^ lowStock.hashCode;
}