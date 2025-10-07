import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao _productDao;
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._productDao, this._remoteDataSource);

  @override
  Stream<List<Product>> watchProducts({String? searchQuery, bool lowStock = false}) {
    return _productDao.watchAllProducts(searchQuery: searchQuery, lowStock: lowStock);
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
    // Mark as pending creation for synchronization
    await _productDao.insertProduct(product.copyWith(
      syncStatus: SyncStatus.pending_create,
    ));
  }

  @override
  Future<void> updateProduct(Product product) async {
    // Mark as pending update for synchronization
    await _productDao.updateProduct(product.copyWith(
      syncStatus: SyncStatus.pending_update,
    ));
  }

  @override
  Future<void> deleteProduct(String id) async {
    final product = await _productDao.getProductById(id);
    if (product != null) {
      // Soft delete: Mark for deletion instead of immediate removal
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
  Future<void> syncProducts() async {
    // Sync local changes to remote
    final unsyncedProducts = await getUnsyncedProducts();
    for (final product in unsyncedProducts) {
      try {
        if (product.syncStatus == SyncStatus.pending_delete) {
          // In a real app, you would call a delete endpoint.
          // For now, we assume success and perform a hard delete locally.
          await _productDao.deleteProduct(product.id);
        } else {
          // This assumes the remote source returns the updated (and now synced) product
          final remoteProduct = await _remoteDataSource.createOrUpdateProduct(product);
          // Mark as synced after successful remote update
          await _productDao.updateProduct(
            remoteProduct.copyWith(syncStatus: SyncStatus.synced),
          );
        }
      } catch (e) {
        // Handle sync error, maybe log it or retry later
      }
    }

    // Sync remote changes to local
    final remoteProducts = await _remoteDataSource.getProducts();
    for (final remoteProduct in remoteProducts) {
      final localProduct = await _productDao.getProductById(remoteProduct.id);
      if (localProduct == null) {
        // Add new product from remote
        await _productDao.insertProduct(
          remoteProduct.copyWith(syncStatus: SyncStatus.synced),
        );
      } else {
        // Conflict resolution: server data wins.
        await _productDao.updateProduct(
          remoteProduct.copyWith(syncStatus: SyncStatus.synced),
        );
      }
    }
  }

  @override
  Future<List<Product>> getTopStockedProducts({int limit = 5}) {
    return _productDao.getTopStockedProducts(limit);
  }

  @override
  Future<List<Product>> getAllProducts() {
    return _productDao.getAllProducts();
  }
}