import 'package:inventory_management_app/domain/entities/product.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';

class GetProductByBarcode {
  final ProductRepository repository;

  GetProductByBarcode(this.repository);

  Future<Product?> call(String barcode) {
    return repository.getProductByBarcode(barcode);
  }
}