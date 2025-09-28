import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/domain/entities/supplier.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';

class EditSupplierScreen extends ConsumerStatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({super.key, required this.supplier});

  @override
  ConsumerState<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends ConsumerState<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _contactNameController =
        TextEditingController(text: widget.supplier.contactName);
    _emailController = TextEditingController(text: widget.supplier.email);
    _phoneController = TextEditingController(text: widget.supplier.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateSupplier() async {
    if (_formKey.currentState!.validate()) {
      final updatedSupplier = Supplier(
        id: widget.supplier.id,
        name: _nameController.text,
        contactName: _contactNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      try {
        await ref.read(updateSupplierProvider).call(updatedSupplier);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier updated successfully')),
          );
          // Pop twice to go back to the suppliers list
          context.pop();
          context.pop();
          // Invalidate the provider to ensure the detail screen rebuilds with new data
          ref.invalidate(supplierDetailProvider(widget.supplier.id));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating supplier: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a supplier name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateSupplier,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}