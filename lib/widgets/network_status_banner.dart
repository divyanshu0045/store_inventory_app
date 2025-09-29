import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/core/services/service_providers.dart';
import 'package:inventory_management_app/core/services/sync_state.dart';

class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityResult = ref.watch(connectivityStreamProvider);
    final syncState = ref.watch(syncStateProvider);

    if (connectivityResult.hasValue &&
        connectivityResult.value == ConnectivityResult.none) {
      return _buildBanner(
        context: context,
        message: 'You are currently offline.',
        color: Colors.grey,
        icon: Icons.wifi_off,
      );
    }

    if (syncState == SyncState.syncing) {
      return _buildBanner(
        context: context,
        message: 'Syncing data...',
        color: Colors.blue,
        icon: Icons.sync,
      );
    }

    // You could use another provider with a timer to hide the success/error banners after a few seconds
    if (syncState == SyncState.success) {
      return _buildBanner(
        context: context,
        message: 'Sync successful.',
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    }

    if (syncState == SyncState.error) {
      return _buildBanner(
        context: context,
        message: 'Sync failed. Please try again.',
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }

    return const SizedBox.shrink(); // No banner to show
  }

  Widget _buildBanner({
    required BuildContext context,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}