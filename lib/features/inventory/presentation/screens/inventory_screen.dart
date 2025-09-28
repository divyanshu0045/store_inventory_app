import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/domain/entities/user.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_filter.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onScanPressed() async {
    final code = await context.push<String>('/scanner');
    if (code == null || !context.mounted) return;

    final getProductByBarcode = ref.read(getProductByBarcodeProvider);
    final product = await getProductByBarcode(code);

    if (product != null) {
      context.push('/inventory/product/${product.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No product found for barcode: $code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productListStreamProvider);
    final currentFilter = ref.watch(inventoryFilterProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(inventorySearchQueryProvider.notifier).state = value;
                },
              )
            : const Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  ref.read(inventorySearchQueryProvider.notifier).state = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          PopupMenuButton<InventoryFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              ref.read(inventoryFilterProvider.notifier).state = filter;
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<InventoryFilter>>[
              CheckedPopupMenuItem<InventoryFilter>(
                value: InventoryFilter.all,
                checked: currentFilter == InventoryFilter.all,
                child: const Text('All Products'),
              ),
              CheckedPopupMenuItem<InventoryFilter>(
                value: InventoryFilter.lowStock,
                checked: currentFilter == InventoryFilter.lowStock,
                child: const Text('Low Stock'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _onScanPressed,
          ),
        ],
      ),
      body: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
                child: Text(_isSearching || currentFilter == InventoryFilter.lowStock
                    ? 'No products match your criteria.'
                    : 'No products found. Add one!'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Dismissible(
                key: ValueKey(product.id),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) { // Delete
                    if (currentUser?.role != UserRole.admin) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Only admins can delete products.')));
                      return false;
                    }
                    final bool? confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Product?'),
                        content: Text('Are you sure you want to delete "${product.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(deleteProductProvider).call(product.id);
                      return true;
                    }
                    return false;
                  } else { // Edit
                    if (currentUser?.role != UserRole.admin && currentUser?.role != UserRole.staff) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('You do not have permission to edit products.')));
                      return false;
                    }
                    context.push('/edit-product', extra: product);
                    return false; // Don't dismiss the item
                  }
                },
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('SKU: ${product.sku}'),
                  trailing: Text('Qty: ${product.stockQuantity}'),
                  onTap: () {
                    context.push('/inventory/product/${product.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(productListStreamProvider);
                },
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: RoleRestrictedWidget(
        allowedRoles: const [UserRole.admin, UserRole.staff],
        child: FloatingActionButton(
          onPressed: () {
            context.push('/add-product');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}