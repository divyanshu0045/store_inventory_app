import 'package:inventory_management_app/domain/entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchProducts({String? searchQuery, bool lowStock = false});
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> syncProducts();
  Future<int> getProductCount();
  Future<int> getLowStockCount();
}