import 'package:inventory_management_app/domain/entities/supplier.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class AddSupplier {
  final SupplierRepository repository;

  AddSupplier(this.repository);

  Future<void> call(Supplier supplier) {
    return repository.addSupplier(supplier);
  }
}