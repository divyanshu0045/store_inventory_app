import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/remote/api_client.dart';

abstract class ProductRemoteDataSource {
  Future<List<db.Product>> getProducts();
  Future<db.Product> createProduct(db.Product product);
  Future<db.Product> updateProduct(String id, db.Product product);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<db.Product>> getProducts() async {
    try {
      final response = await _apiClient.get('/products');
      final products = (response.data as List)
          .map((productJson) => db.Product.fromJson(productJson))
          .toList();
      return products;
    } catch (e) {
      // In a real app, handle different error types (network, server, etc.)
      throw Exception('Failed to load products from API: $e');
    }
  }

  @override
  Future<db.Product> createProduct(db.Product product) async {
    try {
      final response = await _apiClient.post(
        '/products',
        data: product.toJson(),
      );
      return db.Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<db.Product> updateProduct(String id, db.Product product) async {
    try {
      final response = await _apiClient.put(
        '/products/$id',
        data: product.toJson(),
      );
      return db.Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete('/products/$id');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}