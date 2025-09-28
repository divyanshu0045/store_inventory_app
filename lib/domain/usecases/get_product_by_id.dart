import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class GetProductById {
  final ProductRepository repository;

  GetProductById(this.repository);

  Future<Product?> call(String id) {
    return repository.getProductById(id);
  }
}