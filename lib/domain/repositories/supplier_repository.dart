import 'package:inventory_management_app/data/datasources/local/database.dart' as db;

abstract class SupplierRepository {
  Stream<List<db.Supplier>> watchSuppliers({String? searchQuery});

  Future<List<db.Supplier>> getSuppliers();

  Future<db.Supplier?> getSupplierById(String id);

  Future<void> addSupplier(db.Supplier supplier);

  Future<void> updateSupplier(db.Supplier supplier);

  Future<void> deleteSupplier(String id);

  Future<List<db.Supplier>> getUnsyncedSuppliers();
}