import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class WatchProducts {
  final ProductRepository repository;

  WatchProducts(this.repository);

  Stream<List<Product>> call({String? searchQuery, bool lowStock = false}) {
    return repository.watchProducts(
        searchQuery: searchQuery, lowStock: lowStock);
  }
}