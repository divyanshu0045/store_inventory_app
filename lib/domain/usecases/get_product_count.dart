import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class GetProductCount {
  final ProductRepository repository;

  GetProductCount(this.repository);

  Future<int> call() {
    return repository.getProductCount();
  }
}