import 'package:inventory_management_app/core/errors/failures.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:inventory_management_app/domain/entities/product.dart' as domain;
import 'package:inventory_management_app/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/data/models/product_model.dart'
    as model;

class ProductRepositoryImpl implements ProductRepository {
  final db.ProductDao _productDao;
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._productDao, this._remoteDataSource);

  @override
  Stream<List<domain.Product>> watchProducts(
      {String? searchQuery, bool lowStock = false}) {
    return _productDao
        .watchAllProducts(searchQuery: searchQuery, lowStock: lowStock)
        .map((products) => products
            .where((p) => p.syncStatus != db.SyncStatus.pending_delete.index)
            .map((p) => _mapDbProductToDomainProduct(p))
            .toList());
  }

  @override
  Future<List<domain.Product>> getProducts() async {
    final products = await _productDao.watchAllProducts().first;
    return products.map((p) => _mapDbProductToDomainProduct(p)).toList();
  }

  @override
  Future<domain.Product?> getProductById(String id) async {
    final product = await _productDao.getProductById(id);
    return product != null ? _mapDbProductToDomainProduct(product) : null;
  }

  @override
  Future<domain.Product?> getProductByBarcode(String barcode) async {
    final product = await _productDao.getProductByBarcode(barcode);
    return product != null ? _mapDbProductToDomainProduct(product) : null;
  }

  @override
  Future<void> addProduct(domain.Product product) async {
    final dbProduct = _mapDomainProductToDbProduct(product)
        .copyWith(syncStatus: db.SyncStatus.pending_create.index);
    await _productDao.insertProduct(dbProduct);
  }

  @override
  Future<void> updateProduct(domain.Product product) async {
    final dbProduct = _mapDomainProductToDbProduct(product)
        .copyWith(syncStatus: db.SyncStatus.pending_update.index);
    await _productDao.updateProduct(dbProduct);
  }

  @override
  Future<void> deleteProduct(String id) async {
    final product = await _productDao.getProductById(id);
    if (product != null) {
      await _productDao.updateProduct(
          product.copyWith(syncStatus: db.SyncStatus.pending_delete.index));
    }
  }

  @override
  Future<void> syncProducts() async {
    // 1. Push local changes to the remote server
    final unsyncedProducts = await _productDao.getUnsyncedProducts();
    for (final product in unsyncedProducts) {
      try {
        if (product.syncStatus == db.SyncStatus.pending_delete.index) {
          // In a real app, you'd call a delete endpoint.
          // For now, we assume success and delete locally.
          await _productDao.deleteProduct(product.id);
        } else {
          final remoteProduct = await _remoteDataSource
              .createOrUpdateProduct(_mapDbProductToProductModel(product));
          await _productDao.updateProduct(_mapProductModelToDbProduct(remoteProduct)
              .copyWith(syncStatus: db.SyncStatus.synced.index));
        }
      } catch (e) {
        // Handle sync error
      }
    }

    // 2. Fetch remote changes and merge them
    final remoteProducts = await _remoteDataSource.getProducts();
    for (final remoteProduct in remoteProducts) {
      final localProduct = await _productDao.getProductById(remoteProduct.id);
      if (localProduct == null) {
        await _productDao.insertProduct(_mapProductModelToDbProduct(remoteProduct)
            .copyWith(syncStatus: db.SyncStatus.synced.index));
      }
    }
  }

  domain.Product _mapDbProductToDomainProduct(db.Product product) {
    return domain.Product(
      id: product.id,
      name: product.name,
      sku: product.sku,
      description: product.description,
      category: product.category,
      supplierId: product.supplierId,
      barcode: product.barcode,
      stockQuantity: product.stockQuantity,
      location: product.location,
      minimumStockThreshold: product.minimumStockThreshold,
      cost: product.cost,
      sellingPrice: product.sellingPrice,
      imageUrls: product.imageUrls,
      documentUrls: product.documentUrls,
      expiryDate: product.expiryDate,
    );
  }

  db.Product _mapDomainProductToDbProduct(domain.Product product) {
    return db.Product(
      id: product.id,
      name: product.name,
      sku: product.sku,
      syncStatus: db.SyncStatus.synced.index, // Default to synced
      description: product.description,
      category: product.category,
      supplierId: product.supplierId,
      barcode: product.barcode,
      stockQuantity: product.stockQuantity,
      location: product.location,
      minimumStockThreshold: product.minimumStockThreshold,
      cost: product.cost,
      sellingPrice: product.sellingPrice,
      imageUrls: product.imageUrls,
      documentUrls: product.documentUrls,
      expiryDate: product.expiryDate,
    );
  }

  model.ProductModel _mapDbProductToProductModel(db.Product product) {
    return model.ProductModel(
      id: product.id,
      name: product.name,
      sku: product.sku,
      stockQuantity: product.stockQuantity,
    );
  }

  db.Product _mapProductModelToDbProduct(model.ProductModel product) {
    return db.Product(
      id: product.id,
      name: product.name,
      sku: product.sku,
      syncStatus: db.SyncStatus.synced.index,
      stockQuantity: product.stockQuantity,
    );
  }
}