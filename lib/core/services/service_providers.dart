import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inventory_management_app/core/services/connectivity_service.dart';
import 'package:inventory_management_app/core/services/sync_service.dart';
import 'package:inventory_management_app/core/services/sync_state.dart';

final syncStateProvider = StateProvider<SyncState>((ref) => SyncState.idle);

final syncServiceProvider = Provider<SyncService>((ref) {
  // The SyncService now gets its dependencies directly from the ref,
  // so we only need to pass the ref itself.
  return SyncService(ref);
});

// Connectivity Service Providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});