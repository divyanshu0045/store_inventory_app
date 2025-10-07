import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_filter.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stocktake_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';

class FilterScreen extends ConsumerStatefulWidget {
  final ProductFilter initialFilter;
  const FilterScreen({super.key, required this.initialFilter});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late ProductFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  void _applyFilters() {
    context.pop(_currentFilter);
  }

  void _clearFilters() {
    context.pop(const ProductFilter());
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(stocktakeLocationsProvider);
    final categories = ref.watch(stocktakeCategoriesProvider);
    final suppliers = ref.watch(supplierListStreamProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Products'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          locations.when(
            data: (data) => _buildDropdown(
              label: 'Location',
              items: data,
              value: _currentFilter.location,
              onChanged: (value) => setState(() => _currentFilter = _currentFilter.copyWith(location: value)),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Text('Could not load locations'),
          ),
          const SizedBox(height: 16),
          categories.when(
            data: (data) => _buildDropdown(
              label: 'Category',
              items: data,
              value: _currentFilter.category,
              onChanged: (value) => setState(() => _currentFilter = _currentFilter.copyWith(category: value)),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Text('Could not load categories'),
          ),
          const SizedBox(height: 16),
          suppliers.when(
            data: (data) => DropdownButtonFormField<String>(
              value: _currentFilter.supplierId,
              hint: const Text('Select a supplier'),
              isExpanded: true,
              items: data.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (value) => setState(() => _currentFilter = _currentFilter.copyWith(supplierId: value)),
              decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Text('Could not load suppliers'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text('Select a $label'),
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}