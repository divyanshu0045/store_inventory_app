import 'package:inventory_management_app/domain/entities/supplier.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class GetSuppliers {
  final SupplierRepository repository;

  GetSuppliers(this.repository);

  Future<List<Supplier>> call() {
    return repository.getSuppliers();
  }
}