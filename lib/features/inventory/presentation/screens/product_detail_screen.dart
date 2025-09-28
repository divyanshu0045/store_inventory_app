import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/domain/entities/user.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
        await ref.read(deleteProductProvider).call(widget.productId);
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
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Location'),
                      trailing: Text(product.location ?? 'N/A'),
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
                          final isIncome = transaction.type == TransactionType.IN;
                          return ListTile(
                            leading: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
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