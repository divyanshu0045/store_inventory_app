import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/lot_providers.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

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
    // Increase length to 4 for the new "Lots" tab
    _tabController = TabController(length: 4, vsync: this);
    // Add a listener to update the FAB visibility
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
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
                  ? () => context.push('/edit-product', extra: productAsyncValue.value!)
                  : null,
            ),
          ),
          RoleRestrictedWidget(
            allowedRoles: const [UserRole.admin],
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
            Tab(text: 'Lots'),
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
              _buildOverviewTab(context, product),
              _buildLotsTab(context, ref, product),
              _buildTransactionsTab(context, ref, product.id),
              _buildAttachmentsTab(context, product),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: _buildFloatingActionButton(context, productAsyncValue.value),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, Product? product) {
    if (product == null) return null;

    switch (_tabController.index) {
      case 0: // Overview
      case 2: // Transactions
        return FloatingActionButton(
          onPressed: () => context.push('/add-stock-transaction', extra: product),
          tooltip: 'Adjust Stock',
          child: const Icon(Icons.sync_alt),
        );
      case 1: // Lots
        return FloatingActionButton(
          onPressed: () {
            context.push('/add-lot', extra: product);
          },
          tooltip: 'Add Lot',
          child: const Icon(Icons.add),
        );
      case 3: // Attachments
      default:
        return null;
    }
  }

  Widget _buildOverviewTab(BuildContext context, Product product) {
     return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('SKU: ${product.sku}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(leading: const Icon(Icons.inventory_2_outlined), title: const Text('Stock Quantity'), trailing: Text(product.stockQuantity.toString(), style: Theme.of(context).textTheme.titleMedium)),
          ListTile(leading: const Icon(Icons.qr_code), title: const Text('Barcode'), trailing: Text(product.barcode ?? 'N/A')),
          ListTile(leading: const Icon(Icons.business_center_outlined), title: const Text('Supplier'), trailing: product.supplierId != null ? _SupplierName(supplierId: product.supplierId!) : const Text('N/A')),
          ListTile(leading: const Icon(Icons.category_outlined), title: const Text('Category'), trailing: Text(product.category ?? 'N/A')),
          ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Location'), trailing: Text(product.location ?? 'N/A')),
          ListTile(leading: const Icon(Icons.production_quantity_limits), title: const Text('Min. Stock Threshold'), trailing: Text(product.minimumStockThreshold?.toString() ?? 'N/A')),
          ListTile(leading: const Icon(Icons.monetization_on_outlined), title: const Text('Cost Price'), trailing: Text('\$${product.cost?.toStringAsFixed(2) ?? 'N/A'}')),
          ListTile(leading: const Icon(Icons.price_check_outlined), title: const Text('Selling Price'), trailing: Text('\$${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'}')),
          ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Description'), subtitle: Text(product.description ?? 'No description provided.')),
        ],
      ),
    );
  }

  Widget _buildLotsTab(BuildContext context, WidgetRef ref, Product product) {
    final lotsAsyncValue = ref.watch(lotListStreamProvider(product.id));
    return lotsAsyncValue.when(
      data: (lots) {
        if (lots.isEmpty) {
          return const Center(child: Text('No lots for this product.'));
        }
        return ListView.builder(
          itemCount: lots.length,
          itemBuilder: (context, index) {
            final lot = lots[index];
            return Card(
              child: ListTile(
                title: Text('Batch: ${lot.batchNumber}'),
                subtitle: Text('Expires: ${lot.expiryDate != null ? DateFormat.yMd().format(lot.expiryDate!) : 'N/A'}'),
                trailing: Text('Qty: ${lot.quantity}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildTransactionsTab(BuildContext context, WidgetRef ref, String productId) {
    final transactionsAsyncValue = ref.watch(transactionListStreamProvider(productId));
    return transactionsAsyncValue.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Text('No transactions for this product.'));
        }
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final isIncome = transaction.type == TransactionType.IN;
            return ListTile(
              leading: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
              title: Text('${transaction.type.name}: ${transaction.quantity}'),
              subtitle: Text(transaction.reason ?? 'No reason provided'),
              trailing: Text(DateFormat.yMd().add_jm().format(transaction.timestamp)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildAttachmentsTab(BuildContext context, Product product) {
    final imagePaths = product.imageUrls ?? [];
    final docPaths = product.documentUrls ?? [];

    if (imagePaths.isEmpty && docPaths.isEmpty) {
      return const Center(child: Text('No attachments for this product.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagePaths.isNotEmpty) ...[
            Text('Images', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        File(imagePaths[index]),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 120),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (docPaths.isNotEmpty) ...[
            Text('Documents', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docPaths.length,
              itemBuilder: (context, index) {
                final docPath = docPaths[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(path.basename(docPath)),
                  ),
                );
              },
            ),
          ],
        ],
      ),
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
      loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, s) => const Text('Error'),
    );
  }
}