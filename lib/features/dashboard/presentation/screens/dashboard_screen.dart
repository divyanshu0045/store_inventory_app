import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productCount = ref.watch(productCountProvider);
    final lowStockCount = ref.watch(lowStockCountProvider);
    final recentTransactions = ref.watch(recentTransactionsStreamProvider);
    final lowStockProducts = ref.watch(lowStockProductsProvider);
    final topStockedProducts = ref.watch(topStockedProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productCountProvider);
          ref.invalidate(lowStockCountProvider);
          ref.invalidate(recentTransactionsStreamProvider);
          ref.invalidate(lowStockProductsProvider);
          ref.invalidate(topStockedProductsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context: context,
                    title: 'Total Products',
                    value: productCount,
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context: context,
                    title: 'Low Stock Items',
                    value: lowStockCount,
                    icon: Icons.warning_amber_outlined,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLowStockAlerts(context, lowStockProducts),
            const SizedBox(height: 24),
            _buildTopItems(context, topStockedProducts),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            recentTransactions.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('No recent activity.'));
                }
                return Column(
                  children: transactions
                      .map((transaction) =>
                          _TransactionListItem(transaction: transaction))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  const Center(child: Text('Could not load activity.')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required AsyncValue<int> value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 16),
            value.when(
              data: (count) => Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlerts(BuildContext context, AsyncValue<List<db.Product>> lowStockProducts) {
    return lowStockProducts.when(
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Low Stock Alerts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...products.map((product) {
              return Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  title: Text(product.name),
                  trailing: Text('Qty: ${product.stockQuantity}'),
                  onTap: () => context.push('/inventory/product/${product.id}'),
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildTopItems(BuildContext context, AsyncValue<List<db.Product>> topStockedProducts) {
    return topStockedProducts.when(
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Stocked Items', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...products.map((product) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.green),
                  title: Text(product.name),
                  trailing: Text('Qty: ${product.stockQuantity}'),
                  onTap: () => context.push('/inventory/product/${product.id}'),
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _TransactionListItem extends ConsumerWidget {
  final db.StockTransaction transaction;
  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(transaction.productId));
    // The `transaction.type` property is already a `TransactionType` enum.
    final isIncome = transaction.type == db.TransactionType.IN;

    return Card(
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(
          '${transaction.type.name}: ${transaction.quantity}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: product.when(
          data: (p) => Text(p?.name ?? 'Unknown Product'),
          loading: () => const Text('Loading...'),
          error: (e, s) => const Text('Error loading product'),
        ),
        trailing: Text(
          DateFormat.yMd().add_jm().format(transaction.timestamp),
        ),
      ),
    );
  }
}