import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.'),
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
        await ref.read(productRepositoryProvider).deleteProduct(widget.productId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          RoleRestrictedWidget(
            allowedRoles: const [UserRole.admin, UserRole.staff],
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: productAsyncValue.hasValue && productAsyncValue.value != null
                  ? () {
                      context.push('/edit-product', extra: productAsyncValue.value!);
                    }
                  : null,
            ),
          ),
          RoleRestrictedWidget(
            allowedRoles: const [UserRole.admin], // Only admins can delete
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteProduct(context),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Attachments'),
          ],
        ),
      ),
      body: productAsyncValue.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found.'));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SKU: ${product.sku}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: const Text('Stock Quantity'),
                      trailing: Text(
                        product.stockQuantity.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: const Text('Barcode'),
                      trailing: Text(product.barcode ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business_center_outlined),
                      title: const Text('Supplier'),
                      trailing: product.supplierId != null
                          ? _SupplierName(supplierId: product.supplierId!)
                          : const Text('N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Category'),
                      trailing: Text(product.category ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Location'),
                      trailing: Text(product.location ?? 'N/A'),
                    ),
                     ListTile(
                      leading: const Icon(Icons.production_quantity_limits),
                      title: const Text('Min. Stock Threshold'),
                      trailing: Text(product.minimumStockThreshold?.toString() ?? 'N/A'),
                    ),
                     ListTile(
                      leading: const Icon(Icons.monetization_on_outlined),
                      title: const Text('Cost Price'),
                      trailing: Text('\$${product.cost?.toStringAsFixed(2) ?? 'N/A'}'),
                    ),
                     ListTile(
                      leading: const Icon(Icons.price_check_outlined),
                      title: const Text('Selling Price'),
                      trailing: Text('\$${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Description'),
                      subtitle:
                          Text(product.description ?? 'No description provided.'),
                    ),
                  ],
                ),
              ),
              // Transactions Tab
              Consumer(
                builder: (context, ref, child) {
                  final transactionsAsyncValue =
                      ref.watch(transactionListStreamProvider(widget.productId));
                  return transactionsAsyncValue.when(
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return const Center(
                            child: Text('No transactions for this product.'));
                      }
                      return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          // Correctly compare the enum value
                          final isIncome = transaction.type == TransactionType.IN;
                          return ListTile(
                            leading: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                            // Correctly access the enum's name
                            title: Text(
                                '${transaction.type.name}: ${transaction.quantity}'),
                            subtitle: Text(transaction.reason ?? 'No reason provided'),
                            trailing: Text(
                              DateFormat.yMd().add_jm().format(transaction.timestamp),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  );
                },
              ),
              // Attachments Tab
              const Center(
                child: Text('Attachments will be shown here.'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: productAsyncValue.hasValue && productAsyncValue.value != null
          ? FloatingActionButton(
              onPressed: () {
                context.push('/add-stock-transaction',
                    extra: productAsyncValue.value!);
              },
              child: const Icon(Icons.sync_alt),
            )
          : null,
    );
  }
}

class _SupplierName extends ConsumerWidget {
  final String supplierId;
  const _SupplierName({required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsyncValue = ref.watch(supplierDetailProvider(supplierId));
    return supplierAsyncValue.when(
      data: (supplier) => Text(supplier?.name ?? 'Unknown'),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, s) => const Text('Error'),
    );
  }
}