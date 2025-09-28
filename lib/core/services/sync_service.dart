import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class SyncService {
  final ProductRepository _productRepository;

  SyncService(this._productRepository);

  Future<void> sync() async {
    // In a real app, you'd also fetch remote changes here
    // For now, we'll just push local changes
    await _productRepository.syncProducts();
  }
}
