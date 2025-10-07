import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stocktake_providers.dart';

class StocktakeScreen extends ConsumerStatefulWidget {
  const StocktakeScreen({super.key});

  @override
  ConsumerState<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends ConsumerState<StocktakeScreen> {
  String? _selectedLocation;
  String? _selectedCategory;

  void _startCount(StocktakeFilterType type, {String? value}) {
    final filter = StocktakeFilter(type: type, value: value);
    context.push('/stocktake/counting', extra: filter);
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(stocktakeLocationsProvider);
    final categories = ref.watch(stocktakeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocktake / Cycle Count'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Stocktake', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Count all items in your inventory.'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Start Full Count'),
                      onPressed: () => _startCount(StocktakeFilterType.full),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stocktake by Location', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  locations.when(
                    data: (data) => DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      hint: const Text('Select a location'),
                      isExpanded: true,
                      items: data.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                      onChanged: (value) => setState(() => _selectedLocation = value),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Could not load locations'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('Start Count by Location'),
                      onPressed: _selectedLocation != null ? () => _startCount(StocktakeFilterType.location, value: _selectedLocation) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stocktake by Category', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  categories.when(
                    data: (data) => DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: const Text('Select a category'),
                      items: data.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Could not load categories'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.category_outlined),
                      label: const Text('Start Count by Category'),
                      onPressed: _selectedCategory != null ? () => _startCount(StocktakeFilterType.category, value: _selectedCategory) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}