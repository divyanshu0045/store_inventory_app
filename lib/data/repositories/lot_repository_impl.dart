import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/repositories/lot_repository.dart';

class LotRepositoryImpl implements LotRepository {
  final db.LotDao _lotDao;

  LotRepositoryImpl(this._lotDao);

  @override
  Stream<List<db.Lot>> watchLotsForProduct(String productId) {
    return _lotDao.watchLotsForProduct(productId);
  }

  @override
  Future<void> addLot(db.Lot lot) {
    return _lotDao.insertLot(lot);
  }

  @override
  Future<void> updateLot(db.Lot lot) {
    return _lotDao.updateLot(lot);
  }

  @override
  Future<void> deleteLot(String id) {
    return _lotDao.deleteLot(id);
  }
}