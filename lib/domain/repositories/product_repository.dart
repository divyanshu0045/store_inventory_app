import 'package:inventory_management_app/data/datasources/local/database.dart' as db;

abstract class ProductRepository {
  Stream<List<db.Product>> watchProducts({String? searchQuery, bool lowStock = false});

  Future<db.Product?> getProductById(String id);

  Future<db.Product?> getProductByBarcode(String barcode);

  Future<void> addProduct(db.Product product);

  Future<void> updateProduct(db.Product product);

  Future<void> deleteProduct(String id);

  Future<List<db.Product>> getUnsyncedProducts();

  Stream<List<db.Product>> watchProductsBySupplier(String supplierId);

  Future<int> getProductCount();

  Future<int> getLowStockCount();

  Future<void> syncProducts();

  Future<List<db.Product>> getTopStockedProducts({int limit = 5});

  Future<List<db.Product>> getAllProducts();
}