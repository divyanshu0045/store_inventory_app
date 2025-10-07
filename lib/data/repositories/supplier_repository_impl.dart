import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final db.SupplierDao _supplierDao;

  SupplierRepositoryImpl(this._supplierDao);

  @override
  Stream<List<db.Supplier>> watchSuppliers({String? searchQuery}) {
    return _supplierDao.watchAllSuppliers(searchQuery: searchQuery);
  }

  @override
  Future<List<db.Supplier>> getSuppliers() async {
    return await _supplierDao.watchAllSuppliers().first;
  }

  @override
  Future<db.Supplier?> getSupplierById(String id) async {
    return await _supplierDao.getSupplierById(id);
  }

  @override
  Future<void> addSupplier(db.Supplier supplier) async {
    // Mark as pending creation for synchronization
    await _supplierDao.insertSupplier(
      supplier.copyWith(syncStatus: db.SyncStatus.pending_create),
    );
  }

  @override
  Future<void> updateSupplier(db.Supplier supplier) async {
    // Mark as pending update for synchronization
    await _supplierDao.updateSupplier(
      supplier.copyWith(syncStatus: db.SyncStatus.pending_update),
    );
  }

  @override
  Future<void> deleteSupplier(String id) async {
    final supplier = await _supplierDao.getSupplierById(id);
    if (supplier != null) {
      // Soft delete: Mark for deletion instead of immediate removal
      await _supplierDao.updateSupplier(
        supplier.copyWith(syncStatus: db.SyncStatus.pending_delete),
      );
    }
  }

  @override
  Future<List<db.Supplier>> getUnsyncedSuppliers() {
    return _supplierDao.getUnsyncedSuppliers();
  }
}