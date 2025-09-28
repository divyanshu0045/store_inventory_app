import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productCount = ref.watch(productCountProvider);
    final lowStockCount = ref.watch(lowStockCountProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productCountProvider);
          ref.invalidate(lowStockCountProvider);
          ref.invalidate(recentTransactionsProvider);
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
                  children: transactions.map((transaction) {
                    final product = ref.watch(productDetailProvider(transaction.productId));
                    final isIncome = transaction.type == TransactionType.IN;
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
                          error: (e, s) => const Text('Error'),
                        ),
                        trailing: Text(
                          DateFormat.yMd().add_jm().format(transaction.timestamp),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text('Could not load activity.')),
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
}