import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/remote/api_client.dart';

abstract class ProductRemoteDataSource {
  Future<List<db.Product>> getProducts();
  Future<db.Product> createOrUpdateProduct(db.Product product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<db.Product>> getProducts() async {
    // In a real implementation, this would be an API call that returns products.
    // For now, we simulate network latency and return mock data.
    await Future.delayed(const Duration(seconds: 1));
    return [
      db.Product(
        id: 'remote_prod1',
        name: 'Server-Side Mouse',
        sku: 'SSM-001',
        stockQuantity: 100,
        syncStatus: db.SyncStatus.synced, // Pass the enum value directly
        description: 'A mouse that only exists on the server.',
        category: 'Remote Electronics',
      ),
      db.Product(
        id: 'remote_prod2',
        name: 'Cloud Keyboard',
        sku: 'CK-002',
        stockQuantity: 50,
        syncStatus: db.SyncStatus.synced, // Pass the enum value directly
        description: 'A keyboard synced from the cloud.',
        category: 'Remote Accessories',
      ),
    ];
  }

  @override
  Future<db.Product> createOrUpdateProduct(db.Product product) async {
    // In a real implementation, you would make an API call.
    // For now, just simulate a successful API call and return the product,
    // marking it as synced.
    await Future.delayed(const Duration(milliseconds: 500));
    // The copyWith method also expects the enum value, not its index.
    return product.copyWith(syncStatus: db.SyncStatus.synced);
  }
}