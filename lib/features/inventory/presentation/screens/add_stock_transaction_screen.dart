import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/core/errors/failures.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/entities/stock_transaction.dart'
    as domain;
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:uuid/uuid.dart';

class AddStockTransactionScreen extends ConsumerStatefulWidget {
  final Product product;

  const AddStockTransactionScreen({super.key, required this.product});

  @override
  ConsumerState<AddStockTransactionScreen> createState() =>
      _AddStockTransactionScreenState();
}

class _AddStockTransactionScreenState
    extends ConsumerState<AddStockTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _selectedType = TransactionType.IN;
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
      final newTransaction = domain.StockTransaction(
        id: const Uuid().v4(),
        productId: widget.product.id,
        type: _selectedType,
        quantity: int.parse(_quantityController.text),
        timestamp: DateTime.now(),
        reason: _reasonController.text,
      );

      try {
        await ref.read(addStockTransactionProvider).call(newTransaction);
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
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: TransactionType.values
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
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null ||
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