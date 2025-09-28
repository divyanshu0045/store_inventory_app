import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<void> call(Product product) {
    return repository.addProduct(product);
  }
}