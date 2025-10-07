import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stocktake_providers.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao _productDao;

  ProductRepositoryImpl(this._productDao);

  @override
  Stream<List<Product>> watchProducts({
    String? searchQuery,
    bool lowStock = false,
    String? location,
    String? category,
    String? supplierId,
  }) {
    return _productDao.watchAllProducts(
      searchQuery: searchQuery,
      lowStock: lowStock,
      location: location,
      category: category,
      supplierId: supplierId,
    );
  }

  @override
  Future<Product?> getProductById(String id) {
    return _productDao.getProductById(id);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) {
    return _productDao.getProductByBarcode(barcode);
  }

  @override
  Future<void> addProduct(Product product) async {
    await _productDao.insertProduct(product.copyWith(
      syncStatus: SyncStatus.pending_create,
    ));
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _productDao.updateProduct(product.copyWith(
      syncStatus: SyncStatus.pending_update,
    ));
  }

  @override
  Future<void> deleteProduct(String id) async {
    final product = await _productDao.getProductById(id);
    if (product != null) {
      await _productDao.updateProduct(
        product.copyWith(syncStatus: SyncStatus.pending_delete),
      );
    }
  }

  @override
  Future<List<Product>> getUnsyncedProducts() {
    return _productDao.getUnsyncedProducts();
  }

  @override
  Stream<List<Product>> watchProductsBySupplier(String supplierId) {
    return _productDao.watchProductsBySupplier(supplierId);
  }

  @override
  Future<int> getProductCount() {
    return _productDao.getProductCount();
  }

  @override
  Future<int> getLowStockCount() {
    return _productDao.getLowStockCount();
  }

  @override
  Future<List<Product>> getTopStockedProducts({int limit = 5}) {
    return _productDao.getTopStockedProducts(limit);
  }

  @override
  Future<List<Product>> getAllProducts() {
    return _productDao.getAllProducts();
  }

  @override
  Future<List<String>> getAllLocations() {
    return _productDao.getAllLocations();
  }

  @override
  Future<List<String>> getAllCategories() {
    return _productDao.getAllCategories();
  }

  @override
  Future<List<Product>> getProductsForStocktake(StocktakeFilter filter) {
    switch (filter.type) {
      case StocktakeFilterType.location:
        return _productDao.getProductsBy(location: filter.value);
      case StocktakeFilterType.category:
        return _productDao.getProductsBy(category: filter.value);
      case StocktakeFilterType.full:
        return _productDao.getAllProducts();
    }
  }
}