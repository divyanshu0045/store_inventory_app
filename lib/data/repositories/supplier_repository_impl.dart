import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/entities/supplier.dart' as domain;
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final db.SupplierDao _supplierDao;

  SupplierRepositoryImpl(this._supplierDao);

  @override
  Stream<List<domain.Supplier>> watchSuppliers() {
    return _supplierDao
        .watchAllSuppliers()
        .map((suppliers) => suppliers.map((s) => _mapDbSupplierToDomainSupplier(s)).toList());
  }

  @override
  Future<List<domain.Supplier>> getSuppliers() async {
    final suppliers = await _supplierDao.watchAllSuppliers().first;
    return suppliers.map((s) => _mapDbSupplierToDomainSupplier(s)).toList();
  }

  @override
  Future<domain.Supplier?> getSupplierById(String id) async {
    final supplier = await _supplierDao.getSupplierById(id);
    return supplier != null ? _mapDbSupplierToDomainSupplier(supplier) : null;
  }

  @override
  Future<void> addSupplier(domain.Supplier supplier) async {
    await _supplierDao.insertSupplier(_mapDomainSupplierToDbSupplier(supplier));
  }

  @override
  Future<void> updateSupplier(domain.Supplier supplier) async {
    await _supplierDao.updateSupplier(_mapDomainSupplierToDbSupplier(supplier));
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _supplierDao.deleteSupplier(id);
  }

  domain.Supplier _mapDbSupplierToDomainSupplier(db.Supplier supplier) {
    return domain.Supplier(
      id: supplier.id,
      name: supplier.name,
      contactName: supplier.contactName,
      email: supplier.email,
      phone: supplier.phone,
    );
  }

  db.Supplier _mapDomainSupplierToDbSupplier(domain.Supplier supplier) {
    return db.Supplier(
      id: supplier.id,
      name: supplier.name,
      contactName: supplier.contactName,
      email: supplier.email,
      phone: supplier.phone,
    );
  }
}