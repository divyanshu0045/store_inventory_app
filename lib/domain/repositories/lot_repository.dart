import 'package:inventory_management_app/data/datasources/local/database.dart' as db;

abstract class LotRepository {
  Stream<List<db.Lot>> watchLotsForProduct(String productId);

  Future<void> addLot(db.Lot lot);

  Future<void> updateLot(db.Lot lot);

  Future<void> deleteLot(String id);
}