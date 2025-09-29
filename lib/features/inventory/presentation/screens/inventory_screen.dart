import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_filter.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productListStreamProvider);
    final filter = ref.watch(productFilterProvider);
    final currentUser = ref.watch(authStateStreamProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final searchQuery = await showSearch<String?>(
                context: context,
                delegate: _ProductSearchDelegate(),
              );
              if (searchQuery != null) {
                ref.read(productFilterProvider.notifier).update((state) => state.copyWith(searchQuery: searchQuery));
              }
            },
          ),
          PopupMenuButton<ProductFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (newFilter) {
              ref.read(productFilterProvider.notifier).state = newFilter;
            },
            itemBuilder: (BuildContext context) => [
              CheckedPopupMenuItem<ProductFilter>(
                value: const ProductFilter(lowStock: false),
                checked: !filter.lowStock,
                child: const Text('All Products'),
              ),
              CheckedPopupMenuItem<ProductFilter>(
                value: const ProductFilter(lowStock: true),
                checked: filter.lowStock,
                child: const Text('Low Stock'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final code = await context.push<String>('/scanner');
              if (code == null || !context.mounted) return;
              final product = await ref.read(productRepositoryProvider).getProductByBarcode(code);
              if (product != null && context.mounted) {
                context.push('/inventory/product/${product.id}');
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No product found for barcode: $code')),
                );
              }
            },
          ),
        ],
      ),
      body: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text(filter.searchQuery != null || filter.lowStock ? 'No products match your criteria.' : 'No products found. Add one!'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Dismissible(
                key: ValueKey(product.id),
                confirmDismiss: (direction) async {
                  if (currentUser == null) return false;
                  final isAdmin = currentUser.role == db.UserRole.admin.index;
                  final isStaff = currentUser.role == db.UserRole.staff.index;

                  if (direction == DismissDirection.endToStart) { // Delete
                    if (!isAdmin) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only admins can delete products.')));
                      return false;
                    }
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Product?'),
                        content: Text('Are you sure you want to delete "${product.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    ) ?? false;
                  } else { // Edit
                    if (!isAdmin && !isStaff) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to edit products.')));
                      return false;
                    }
                    context.push('/edit-product', extra: product);
                    return false;
                  }
                },
                onDismissed: (direction) {
                   if (direction == DismissDirection.endToStart) {
                     ref.read(productRepositoryProvider).deleteProduct(product.id);
                   }
                },
                background: Container(color: Colors.blue, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.edit, color: Colors.white)),
                secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
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
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: RoleRestrictedWidget(
        allowedRoles: const [db.UserRole.admin, db.UserRole.staff],
        child: FloatingActionButton(
          onPressed: () => context.push('/add-product'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions can be built here based on the query, for now, it's simple.
    return Container();
  }
}