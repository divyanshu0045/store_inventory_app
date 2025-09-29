import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/features/search/presentation/providers/search_providers.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productResults = ref.watch(productSearchResultsProvider);
    final supplierResults = ref.watch(supplierSearchResultsProvider);
    final searchQuery = ref.watch(globalSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products, suppliers...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(globalSearchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: searchQuery.isEmpty
          ? const Center(
              child: Text('Start typing to search.'),
            )
          : ListView(
              children: [
                if (productResults.hasValue && productResults.value!.isNotEmpty)
                  _buildSectionHeader(context, 'Products'),
                productResults.when(
                  data: (products) => Column(
                    children: products
                        .map((product) => ListTile(
                              title: Text(product.name),
                              subtitle: Text('SKU: ${product.sku}'),
                              onTap: () => context
                                  .push('/inventory/product/${product.id}'),
                            ))
                        .toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const ListTile(title: Text('Error loading products')),
                ),
                if (supplierResults.hasValue && supplierResults.value!.isNotEmpty)
                  _buildSectionHeader(context, 'Suppliers'),
                supplierResults.when(
                  data: (suppliers) => Column(
                    children: suppliers
                        .map((supplier) => ListTile(
                              title: Text(supplier.name),
                              onTap: () => context
                                  .push('/suppliers/supplier/${supplier.id}'),
                            ))
                        .toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const ListTile(title: Text('Error loading suppliers')),
                ),
                if (productResults.isLoading || supplierResults.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}