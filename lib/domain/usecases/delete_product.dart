import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> call(String id) {
    return repository.deleteProduct(id);
  }
}