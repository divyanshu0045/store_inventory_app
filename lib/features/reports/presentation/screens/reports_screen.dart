import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/features/reports/presentation/providers/reports_providers.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valuation = ref.watch(stockValuationProvider);
    final currencyFormatter = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Valuation Report'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(stockValuationProvider.future),
        child: valuation.when(
          data: (data) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Inventory Value',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(data.totalValue),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Quantity'), numeric: true),
                      DataColumn(label: Text('Cost Price'), numeric: true),
                      DataColumn(label: Text('Total Value'), numeric: true),
                    ],
                    rows: data.products.map((product) {
                      final totalValue = (product.cost ?? 0.0) * product.stockQuantity;
                      return DataRow(
                        cells: [
                          DataCell(Text(product.name)),
                          DataCell(Text(product.sku)),
                          DataCell(Text(product.stockQuantity.toString())),
                          DataCell(Text(currencyFormatter.format(product.cost ?? 0.0))),
                          DataCell(Text(currencyFormatter.format(totalValue))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error generating report: $error'),
          ),
        ),
      ),
    );
  }
}