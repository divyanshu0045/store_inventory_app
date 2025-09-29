import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/lot_repository_impl.dart';
import 'package:inventory_management_app/domain/repositories/lot_repository.dart';

// 1. Repository Provider
final lotRepositoryProvider = Provider<LotRepository>((ref) {
  final dao = ref.watch(lotDaoProvider);
  return LotRepositoryImpl(dao);
});

// 2. StreamProvider to watch all lots for a specific product
final lotListStreamProvider =
    StreamProvider.autoDispose.family<List<db.Lot>, String>((ref, productId) {
  final repository = ref.watch(lotRepositoryProvider);
  return repository.watchLotsForProduct(productId);
});