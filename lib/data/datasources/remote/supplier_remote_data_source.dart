import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/remote/api_client.dart';

abstract class SupplierRemoteDataSource {
  Future<List<db.Supplier>> getSuppliers();
  Future<db.Supplier> createSupplier(db.Supplier supplier);
  Future<db.Supplier> updateSupplier(String id, db.Supplier supplier);
  Future<void> deleteSupplier(String id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final ApiClient _apiClient;

  SupplierRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<db.Supplier>> getSuppliers() async {
    try {
      final response = await _apiClient.get('/suppliers');
      final suppliers = (response.data as List)
          .map((supplierJson) => db.Supplier.fromJson(supplierJson))
          .toList();
      return suppliers;
    } catch (e) {
      throw Exception('Failed to load suppliers from API: $e');
    }
  }

  @override
  Future<db.Supplier> createSupplier(db.Supplier supplier) async {
    try {
      final response = await _apiClient.post(
        '/suppliers',
        data: supplier.toJson(),
      );
      return db.Supplier.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  @override
  Future<db.Supplier> updateSupplier(String id, db.Supplier supplier) async {
    try {
      final response = await _apiClient.put(
        '/suppliers/$id',
        data: supplier.toJson(),
      );
      return db.Supplier.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _apiClient.delete('/suppliers/$id');
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
    }
  }
}