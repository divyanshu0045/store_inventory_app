import 'package:inventory_management_app/domain/entities/supplier.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

class WatchSuppliers {
  final SupplierRepository repository;

  WatchSuppliers(this.repository);

  Stream<List<Supplier>> call() {
    return repository.watchSuppliers();
  }
}