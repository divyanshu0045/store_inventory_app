import 'package:inventory_management_app/domain/entities/supplier.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class GetSupplierById {
  final SupplierRepository repository;

  GetSupplierById(this.repository);

  Future<Supplier?> call(String id) {
    return repository.getSupplierById(id);
  }
}