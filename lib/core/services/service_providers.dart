import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/core/services/sync_service.dart';
import 'package:inventory_management_app/core/services/sync_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';

final syncStateProvider = StateProvider<SyncState>((ref) => SyncState.idle);

final syncServiceProvider = Provider<SyncService>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  // In a real app, you would also pass other repositories (suppliers, etc.)
  return SyncService(productRepository, ref);
});