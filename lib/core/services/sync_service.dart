import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/core/services/service_providers.dart';
import 'package:inventory_management_app/core/services/sync_state.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class SyncService {
  final ProductRepository _productRepository;
  final Ref _ref;

  SyncService(this._productRepository, this._ref);

  Future<void> sync() async {
    _ref.read(syncStateProvider.notifier).state = SyncState.syncing;
    try {
      await _productRepository.syncProducts();
      _ref.read(syncStateProvider.notifier).state = SyncState.success;
    } catch (e) {
      _ref.read(syncStateProvider.notifier).state = SyncState.error;
    }
  }
}