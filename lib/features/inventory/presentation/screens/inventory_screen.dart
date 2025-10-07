import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_filter.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Inventory'),
            actions: _buildAppBarActions(context, ref, isTablet),
          ),
          body: Row(
            children: [
              Expanded(
                flex: isTablet ? 1 : 3,
                child: _ProductList(
                  onProductSelected: (productId) {
                    if (isTablet) {
                      setState(() {
                        _selectedProductId = productId;
                      });
                    } else {
                      context.push('/inventory/product/$productId');
                    }
                  },
                  selectedProductId: _selectedProductId,
                ),
              ),
              if (isTablet && _selectedProductId != null)
                Expanded(
                  flex: 2,
                  child: ProductDetailScreen(
                    key: ValueKey(_selectedProductId!), // Ensures the widget rebuilds
                    productId: _selectedProductId!,
                  ),
                ),
               if (isTablet && _selectedProductId == null)
                 const Expanded(
                  flex: 2,
                  child: Center(child: Text('Select a product to see details')),
                ),
            ],
          ),
          floatingActionButton: RoleRestrictedWidget(
            allowedRoles: const [db.UserRole.admin, db.UserRole.staff],
            child: FloatingActionButton(
              onPressed: () => context.push('/add-product'),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, WidgetRef ref, bool isTablet) {
    final filter = ref.watch(productFilterProvider);
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () async {
          final searchQuery = await showSearch<String?>(
            context: context,
            delegate: _ProductSearchDelegate(),
          );
          ref.read(productFilterProvider.notifier).update((state) => state.copyWith(searchQuery: searchQuery ?? ''));
        },
      ),
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: () async {
          final newFilter = await context.push<ProductFilter>(
            '/inventory/filter',
            extra: filter,
          );
          if (newFilter != null) {
            ref.read(productFilterProvider.notifier).state = newFilter;
          }
        },
      ),
      RoleRestrictedWidget(
        allowedRoles: const [db.UserRole.admin, db.UserRole.staff],
        child: IconButton(
          icon: const Icon(Icons.checklist_rtl),
          tooltip: 'Stocktake / Cycle Count',
          onPressed: () => context.push('/stocktake'),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.qr_code_scanner),
        onPressed: () async {
          final code = await context.push<String>('/scanner');
          if (code == null || !context.mounted) return;
          final product = await ref.read(productRepositoryProvider).getProductByBarcode(code);
          if (product != null && context.mounted) {
            if (isTablet) {
              setState(() => _selectedProductId = product.id);
            } else {
              context.push('/inventory/product/${product.id}');
            }
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No product found for barcode: $code')),
            );
          }
        },
      ),
    ];
  }
}

class _ProductList extends ConsumerWidget {
  final Function(String) onProductSelected;
  final String? selectedProductId;

  const _ProductList({required this.onProductSelected, this.selectedProductId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productListStreamProvider);
    final filter = ref.watch(productFilterProvider);
    final currentUser = ref.watch(authStateStreamProvider).value;
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return productsAsyncValue.when(
      data: (products) {
        if (products.isEmpty) {
          final bool isFiltered = filter.searchQuery != null || filter.lowStock || filter.location != null || filter.category != null || filter.supplierId != null;
          return Center(child: Text(isFiltered ? 'No products match your criteria.' : 'No products found. Add one!'));
        }
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Dismissible(
              key: ValueKey(product.id),
              confirmDismiss: (direction) async {
                if (currentUser == null) return false;
                  final isAdmin = currentUser.role == db.UserRole.admin;
                  final isStaff = currentUser.role == db.UserRole.staff;

                if (direction == DismissDirection.endToStart) { // Delete
                  if (!isAdmin) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only admins can delete products.')));
                    return false;
                  }
                  return await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete Product?'), content: Text('Are you sure you want to delete "${product.name}"?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete'))])) ?? false;
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
                selected: isTablet && selectedProductId == product.id,
                onTap: () => onProductSelected(product.id),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return Container();
  }
  @override
  Widget buildSuggestions(BuildContext context) => Container();
}