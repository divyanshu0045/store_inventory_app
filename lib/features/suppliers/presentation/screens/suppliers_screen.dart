import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/domain/entities/user.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';
import 'package:inventory_management_app/widgets/role_restricted_widget.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsyncValue = ref.watch(supplierListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: suppliersAsyncValue.when(
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return const Center(child: Text('No suppliers found. Add one!'));
          }
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                title: Text(supplier.name),
                subtitle: Text(supplier.email ?? 'No email'),
                onTap: () {
                  context.push('/suppliers/supplier/${supplier.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: RoleRestrictedWidget(
        allowedRoles: const [UserRole.admin, UserRole.staff],
        child: FloatingActionButton(
          onPressed: () {
            context.push('/add-supplier');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}