import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/supplier_repository_impl.dart';
import 'package:inventory_management_app/domain/repositories/supplier_repository.dart';

// 1. Repository Provider
// This provider creates the SupplierRepositoryImpl but exposes it as the
// abstract SupplierRepository, adhering to dependency inversion.
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final dao = ref.watch(supplierDaoProvider);
  return SupplierRepositoryImpl(dao);
});

// 2. StreamProvider for the supplier list with search capability
// This provider watches the stream of suppliers from the repository.
// The `.family` modifier allows passing a search query to filter the list.
final supplierListStreamProvider =
    StreamProvider.autoDispose.family<List<db.Supplier>, String?>((ref, searchQuery) {
  final repository = ref.watch(supplierRepositoryProvider);
  // If the search query is empty, it should be treated as null to fetch all suppliers.
  final query = (searchQuery?.isEmpty ?? true) ? null : searchQuery;
  return repository.watchSuppliers(searchQuery: query);
});

// 3. FutureProvider for fetching a single supplier
// Fetches a single supplier by their ID. The `.family` modifier allows
// passing the ID as a parameter.
final supplierDetailProvider =
    FutureProvider.autoDispose.family<db.Supplier?, String>((ref, id) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getSupplierById(id);
});