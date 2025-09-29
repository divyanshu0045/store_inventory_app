import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Note: The recent transactions stream is now provided by
// `recentTransactionsStreamProvider` in `stock_transaction_providers.dart`
// and should be used directly by the dashboard UI.