import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/domain/entities/user.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';

class RoleRestrictedWidget extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;

  const RoleRestrictedWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser != null && allowedRoles.contains(currentUser.role)) {
      return child;
    }

    return const SizedBox.shrink();
  }
}