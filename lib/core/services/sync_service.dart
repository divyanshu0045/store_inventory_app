import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/core/services/service_providers.dart';
import 'package:inventory_management_app/core/services/sync_state.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';

class SyncService {
  final Ref _ref;
  // Get repositories directly from the ref
  ProductRepository get _productRepository => _ref.read(productRepositoryProvider);
  SupplierRepository get _supplierRepository => _ref.read(supplierRepositoryProvider);

  SyncService(this._ref);

  Future<void> performSync() async {
    final syncStateNotifier = _ref.read(syncStateProvider.notifier);

    if (syncStateNotifier.state == SyncState.syncing) return;

    syncStateNotifier.state = SyncState.syncing;

    try {
      await _syncProducts();
      await _syncSuppliers();
      syncStateNotifier.state = SyncState.success;
    } catch (e) {
      syncStateNotifier.state = SyncState.error;
      // In a real app, log the error
      print('Sync failed: $e');
    }
  }

  Future<void> _syncProducts() async {
    final unsyncedProducts = await _productRepository.getUnsyncedProducts();

    // Push local changes to remote
    for (final product in unsyncedProducts) {
      if (product.syncStatus == SyncStatus.pending_delete) {
        // await _productRemoteDataSource.deleteProduct(product.id); // In a real app
        await _productRepository.deleteProduct(product.id); // For mock, just delete locally
      } else {
        // await _productRemoteDataSource.updateProduct(product.id, product); // In a real app
      }
    }

    // Pull remote changes to local
    // final remoteProducts = await _productRemoteDataSource.getProducts(); // In a real app
    // For now, we assume the remote is the single source of truth and we just
    // overwrite local data. In a real app, you'd need conflict resolution.
    // for (final remoteProduct in remoteProducts) {
    //   await _productRepository.updateProduct(remoteProduct.copyWith(syncStatus: SyncStatus.synced));
    // }
  }

  Future<void> _syncSuppliers() async {
    final unsyncedSuppliers = await _supplierRepository.getUnsyncedSuppliers();

    // Push local changes to remote
    for (final supplier in unsyncedSuppliers) {
      if (supplier.syncStatus == SyncStatus.pending_delete) {
        await _supplierRepository.deleteSupplier(supplier.id);
      } else {
        // await _supplierRemoteDataSource.updateSupplier(supplier.id, supplier); // In a real app
      }
    }
  }
}