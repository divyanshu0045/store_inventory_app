import 'package:flutter/foundation.dart';

@immutable
class ProductFilter {
  final String? searchQuery;
  final bool lowStock;
  final String? location;
  final String? category;
  final String? supplierId;

  const ProductFilter({
    this.searchQuery,
    this.lowStock = false,
    this.location,
    this.category,
    this.supplierId,
  });

  ProductFilter copyWith({
    String? searchQuery,
    bool? lowStock,
    String? location,
    String? category,
    String? supplierId,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      lowStock: lowStock ?? this.lowStock,
      location: location ?? this.location,
      category: category ?? this.category,
      supplierId: supplierId ?? this.supplierId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductFilter &&
        other.searchQuery == searchQuery &&
        other.lowStock == lowStock &&
        other.location == location &&
        other.category == category &&
        other.supplierId == supplierId;
  }

  @override
  int get hashCode {
    return searchQuery.hashCode ^
        lowStock.hashCode ^
        location.hashCode ^
        category.hashCode ^
        supplierId.hashCode;
  }
}