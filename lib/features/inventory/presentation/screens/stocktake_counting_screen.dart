import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stocktake_providers.dart';
import 'package:uuid/uuid.dart';

class StocktakeCountingScreen extends ConsumerStatefulWidget {
  final StocktakeFilter filter;
  const StocktakeCountingScreen({super.key, required this.filter});

  @override
  ConsumerState<StocktakeCountingScreen> createState() =>
      _StocktakeCountingScreenState();
}

class _StocktakeCountingScreenState
    extends ConsumerState<StocktakeCountingScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCount() async {
    final products = ref.read(stocktakeProductsProvider(widget.filter)).value;
    if (products == null) return;

    final transactionRepo = ref.read(stockTransactionRepositoryProvider);
    int adjustmentsMade = 0;

    for (final product in products) {
      final controller = _controllers[product.id];
      if (controller != null && controller.text.isNotEmpty) {
        final physicalCount = int.tryParse(controller.text);
        if (physicalCount != null && physicalCount != product.stockQuantity) {
          final adjustmentQuantity = physicalCount - product.stockQuantity;

          final newTransaction = db.StockTransaction(
            id: const Uuid().v4(),
            productId: product.id,
            lotId: null, // No specific lot, repository will handle adjustment
            type: db.TransactionType.ADJUST,
            quantity: adjustmentQuantity,
            timestamp: DateTime.now(),
            reason: 'Stocktake adjustment',
          );
          await transactionRepo.addTransaction(newTransaction);
          adjustmentsMade++;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stocktake complete. $adjustmentsMade adjustments made.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(stocktakeProductsProvider(widget.filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Counts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: productsAsyncValue.hasValue ? _saveCount : null,
            tooltip: 'Save Count',
          ),
        ],
      ),
      body: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
                child: Text('No products found for this selection.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              _controllers.putIfAbsent(
                  product.id, () => TextEditingController(text: product.stockQuantity.toString()));
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('SKU: ${product.sku}\nSystem Qty: ${product.stockQuantity}'),
                  trailing: SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _controllers[product.id],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Counted',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading products: $error'),
        ),
      ),
    );
  }
}