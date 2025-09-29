import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';

class SupplierDetailScreen extends ConsumerWidget {
  final String supplierId;

  const SupplierDetailScreen({
    super.key,
    required this.supplierId,
  });

  Future<void> _deleteSupplier(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier?'),
        content: const Text(
            'Are you sure you want to delete this supplier? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(supplierRepositoryProvider).deleteSupplier(supplierId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier deleted successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting supplier: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsyncValue = ref.watch(supplierDetailProvider(supplierId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Details'),
        actions: [
          RoleRestrictedWidget(
            allowedRoles: const [db.UserRole.admin, db.UserRole.staff],
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: supplierAsyncValue.hasValue && supplierAsyncValue.value != null
                  ? () {
                      context.push('/edit-supplier', extra: supplierAsyncValue.value!);
                    }
                  : null,
            ),
          ),
          RoleRestrictedWidget(
            allowedRoles: const [db.UserRole.admin],
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSupplier(context, ref),
            ),
          ),
        ],
      ),
      body: supplierAsyncValue.when(
        data: (supplier) {
          if (supplier == null) {
            return const Center(child: Text('Supplier not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Contact Name'),
                  subtitle: Text(supplier.contactName ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(supplier.email ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text(supplier.phone ?? 'N/A'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Products from this Supplier',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _buildProductList(ref),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildProductList(WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsBySupplierStreamProvider(supplierId));
    return productsAsyncValue.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('No products from this supplier.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text('SKU: ${product.sku}'),
                trailing: Text('Qty: ${product.stockQuantity}'),
                onTap: () => context.push('/inventory/product/${product.id}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Could not load products.')),
    );
  }
}