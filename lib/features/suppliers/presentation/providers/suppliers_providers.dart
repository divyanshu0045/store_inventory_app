import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/supplier_repository_impl.dart';
import 'package:inventory_management_app/domain/entities/supplier.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';
import 'package:inventory_management_app/domain/usecases/add_supplier.dart';
import 'package:inventory_management_app/domain/usecases/delete_supplier.dart';
import 'package:inventory_management_app/domain/usecases/get_supplier_by_id.dart';
import 'package:inventory_management_app/domain/usecases/update_supplier.dart';
import 'package:inventory_management_app/domain/usecases/watch_suppliers.dart';

// 1. Repository Provider
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final dao = ref.watch(supplierDaoProvider);
  return SupplierRepositoryImpl(dao);
});

// 2. Use Case Provider
final watchSuppliersProvider = Provider<WatchSuppliers>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return WatchSuppliers(repository);
});

// 3. StreamProvider for the supplier list
final supplierListStreamProvider =
    StreamProvider.autoDispose<List<Supplier>>((ref) {
  final watchSuppliers = ref.watch(watchSuppliersProvider);
  return watchSuppliers();
});

// 4. Provider for the AddSupplier use case
final addSupplierProvider = Provider<AddSupplier>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return AddSupplier(repository);
});

// 5. Provider for the GetSupplierById use case
final getSupplierByIdProvider = Provider<GetSupplierById>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return GetSupplierById(repository);
});

// 6. FutureProvider.family for fetching a single supplier
final supplierDetailProvider =
    FutureProvider.autoDispose.family<Supplier?, String>((ref, id) {
  final getSupplierById = ref.watch(getSupplierByIdProvider);
  return getSupplierById(id);
});

// 7. Provider for the DeleteSupplier use case
final deleteSupplierProvider = Provider<DeleteSupplier>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return DeleteSupplier(repository);
});

// 8. Provider for the UpdateSupplier use case
final updateSupplierProvider = Provider<UpdateSupplier>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return UpdateSupplier(repository);
});