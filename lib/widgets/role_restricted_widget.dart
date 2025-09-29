import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';

class RoleRestrictedWidget extends ConsumerWidget {
  final List<db.UserRole> allowedRoles;
  final Widget child;

  const RoleRestrictedWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateStreamProvider);
    final currentUser = authState.value;

    // The `currentUser.role` is already a `db.UserRole` enum due to the converter.
    // We just need to check if the list of allowed roles contains the user's role.
    if (currentUser != null && allowedRoles.contains(currentUser.role)) {
      return child;
    }

    return const SizedBox.shrink();
  }
}