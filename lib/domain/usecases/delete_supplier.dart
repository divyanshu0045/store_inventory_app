import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  Future<void> call(String id) {
    return repository.deleteSupplier(id);
  }
}