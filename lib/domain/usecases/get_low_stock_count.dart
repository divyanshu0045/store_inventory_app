import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class GetLowStockCount {
  final ProductRepository repository;

  GetLowStockCount(this.repository);

  Future<int> call() {
    return repository.getLowStockCount();
  }
}