import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/lot_providers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddLotScreen extends ConsumerStatefulWidget {
  final db.Product product;
  const AddLotScreen({super.key, required this.product});

  @override
  ConsumerState<AddLotScreen> createState() => _AddLotScreenState();
}

class _AddLotScreenState extends ConsumerState<AddLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batchNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _expiryDate;

  @override
  void dispose() {
    _batchNumberController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Future<void> _saveLot() async {
    if (_formKey.currentState!.validate()) {
      final newLot = db.Lot(
        id: const Uuid().v4(),
        productId: widget.product.id,
        batchNumber: _batchNumberController.text,
        quantity: int.parse(_quantityController.text),
        expiryDate: _expiryDate,
      );

      try {
        final lotRepo = ref.read(lotRepositoryProvider);
        final productRepo = ref.read(productRepositoryProvider);

        // This should ideally be a single transaction in the repository layer
        await lotRepo.addLot(newLot);

        // Update the product's total stock quantity
        final lots = await lotRepo.watchLotsForProduct(widget.product.id).first;
        final totalStock = lots.fold<int>(0, (sum, lot) => sum + lot.quantity);
        await productRepo.updateProduct(widget.product.copyWith(stockQuantity: totalStock));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lot added successfully')),
          );
          ref.invalidate(lotListStreamProvider(widget.product.id));
          ref.invalidate(productDetailProvider(widget.product.id));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding lot: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Lot to ${widget.product.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _batchNumberController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a batch number' : null,
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
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid, positive quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (Optional)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _presentDatePicker,
                  ),
                ),
                controller: TextEditingController(
                  text: _expiryDate == null ? '' : DateFormat.yMd().format(_expiryDate!),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLot,
                child: const Text('Save Lot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}