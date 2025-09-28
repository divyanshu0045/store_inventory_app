import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/domain/usecases/get_low_stock_count.dart';
import 'package:inventory_management_app/domain/usecases/get_product_count.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';

// 1. Use Case Providers
final getProductCountProvider = Provider<GetProductCount>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductCount(repository);
});

final getLowStockCountProvider = Provider<GetLowStockCount>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetLowStockCount(repository);
});

// 2. FutureProviders for dashboard data
final productCountProvider = FutureProvider.autoDispose<int>((ref) {
  final getProductCount = ref.watch(getProductCountProvider);
  return getProductCount();
});

final lowStockCountProvider = FutureProvider.autoDispose<int>((ref) {
  final getLowStockCount = ref.watch(getLowStockCountProvider);
  return getLowStockCount();
});