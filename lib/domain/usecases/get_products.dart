import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call() {
    return repository.getProducts();
  }
}