import 'package:inventory_management_app/data/datasources/remote/api_client.dart';
import 'package:inventory_management_app/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createOrUpdateProduct(ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    // In a real implementation, this would be an API call.
    // For now, we simulate fetching data from the server.
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    return [
      ProductModel(
        id: 'remote_prod1',
        name: 'Server-Side Mouse',
        sku: 'SSM-001',
        stockQuantity: 100,
        description: 'A mouse that only exists on the server.',
        category: 'Remote Electronics',
      ),
      ProductModel(
        id: 'remote_prod2',
        name: 'Cloud Keyboard',
        sku: 'CK-002',
        stockQuantity: 50,
        description: 'A keyboard synced from the cloud.',
        category: 'Remote Accessories',
      ),
    ];
  }

  @override
  Future<ProductModel> createOrUpdateProduct(ProductModel product) async {
    // In a real implementation, you would make an API call like this:
    // final response = await _apiClient.post('/products', data: product.toJson());
    // return ProductModel.fromJson(response.data);

    // For now, just return the product to simulate a successful API call
    await Future.delayed(const Duration(milliseconds: 500));
    return product;
  }
}