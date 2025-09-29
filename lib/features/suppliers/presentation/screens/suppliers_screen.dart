import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final suppliersAsyncValue = ref.watch(supplierListStreamProvider(searchQuery));
    final currentUser = ref.watch(authStateStreamProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by supplier name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface.withAlpha(50),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ),
      ),
      body: suppliersAsyncValue.when(
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return Center(child: Text(searchQuery.isEmpty ? 'No suppliers found. Add one!' : 'No suppliers match your search.'));
          }
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Dismissible(
                key: ValueKey(supplier.id),
                confirmDismiss: (direction) async {
                  if (currentUser == null) return false;

                  if (direction == DismissDirection.endToStart) { // Delete
                    if (currentUser.role != db.UserRole.admin.index) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Only admins can delete suppliers.')));
                      return false;
                    }
                    final bool? confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Supplier?'),
                        content: Text('Are you sure you want to delete "${supplier.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(supplierRepositoryProvider).deleteSupplier(supplier.id);
                      return true;
                    }
                    return false;
                  } else { // Edit
                    if (currentUser.role != db.UserRole.admin.index && currentUser.role != db.UserRole.staff.index) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('You do not have permission to edit suppliers.')));
                      return false;
                    }
                    context.push('/edit-supplier', extra: supplier);
                    return false;
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
                  title: Text(supplier.name),
                  subtitle: Text(supplier.contactName ?? supplier.email ?? 'No contact info'),
                  onTap: () => context.push('/suppliers/supplier/${supplier.id}'),
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
          onPressed: () => context.push('/add-supplier'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}