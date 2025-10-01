import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/core/errors/failures.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/lot_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:uuid/uuid.dart';

class AddStockTransactionScreen extends ConsumerStatefulWidget {
  final db.Product product;

  const AddStockTransactionScreen({super.key, required this.product});

  @override
  ConsumerState<AddStockTransactionScreen> createState() =>
      _AddStockTransactionScreenState();
}

class _AddStockTransactionScreenState
    extends ConsumerState<AddStockTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  db.TransactionType _selectedType = db.TransactionType.IN;
  String? _selectedLotId;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLotId == null && _selectedType != db.TransactionType.ADJUST) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a lot for IN/OUT transactions.')),
        );
        return;
      }

      final newTransaction = db.StockTransaction(
        id: const Uuid().v4(),
        productId: widget.product.id,
        lotId: _selectedLotId,
        type: _selectedType,
        quantity: int.parse(_quantityController.text),
        timestamp: DateTime.now(),
        reason: _reasonController.text,
      );

      try {
        await ref
            .read(stockTransactionRepositoryProvider)
            .addTransaction(newTransaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction saved successfully')),
          );
          context.pop();
        }
      } on InsufficientStockException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lotsAsyncValue = ref.watch(lotListStreamProvider(widget.product.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Adjust Stock: ${widget.product.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<db.TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: db.TransactionType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              lotsAsyncValue.when(
                data: (lots) {
                  if (lots.isEmpty && _selectedType != db.TransactionType.ADJUST) {
                    return const Text('This product has no lots. Please add a lot before creating a transaction.');
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedLotId,
                    decoration: const InputDecoration(
                      labelText: 'Lot / Batch',
                      border: OutlineInputBorder(),
                    ),
                    items: lots
                        .map((lot) => DropdownMenuItem(
                              value: lot.id,
                              child: Text(
                                  'Batch: ${lot.batchNumber} (Qty: ${lot.quantity})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLotId = value;
                      });
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Could not load lots'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Please enter a valid, positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}