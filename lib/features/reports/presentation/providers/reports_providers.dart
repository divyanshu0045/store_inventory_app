import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';

/// A data class to hold the results of the stock valuation calculation.
class StockValuationData {
  final List<db.Product> products;
  final double totalValue;

  StockValuationData({required this.products, required this.totalValue});
}

/// A provider that calculates the total stock valuation.
final stockValuationProvider = FutureProvider.autoDispose<StockValuationData>((ref) async {
  final productRepository = ref.watch(productRepositoryProvider);
  final products = await productRepository.getAllProducts();

  double totalValue = 0.0;
  for (final product in products) {
    totalValue += (product.cost ?? 0.0) * product.stockQuantity;
  }

  return StockValuationData(products: products, totalValue: totalValue);
});