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
    await _supplierDao.insertSupplier(supplier);
  }

  @override
  Future<void> updateSupplier(db.Supplier supplier) async {
    await _supplierDao.updateSupplier(supplier);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _supplierDao.deleteSupplier(id);
  }
}