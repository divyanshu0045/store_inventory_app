import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

enum SyncStatus { synced, pending_create, pending_update, pending_delete }
enum UserRole { admin, staff, viewer }
enum TransactionType { IN, OUT, ADJUST }

// Products Table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  IntColumn get syncStatus => integer().map(const EnumIndexConverter(SyncStatus.values))();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get stockQuantity => integer()();
  TextColumn get location => text().nullable()();
  IntColumn get minimumStockThreshold => integer().nullable()();
  RealColumn get cost => real().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  TextColumn get imageUrls => text().map(const ListConverter()).nullable()();
  TextColumn get documentUrls => text().map(const ListConverter()).nullable()();
  // expiryDate is removed from here and moved to the Lots table

  @override
  Set<Column> get primaryKey => {id};
}

// Lots Table for Batch/Lot Tracking
class Lots extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get batchNumber => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get expiryDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Suppliers Table
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Users Table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get password => text()(); // In a real app, this would be a hash
  IntColumn get role => integer().map(const EnumIndexConverter(UserRole.values))();

  @override
  Set<Column> get primaryKey => {id};
}

// Stock Transactions Table
class StockTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get lotId => text().nullable().references(Lots, #id)(); // Link to a specific lot
  IntColumn get type => integer().map(const EnumIndexConverter(TransactionType.values))();
  IntColumn get quantity => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Type Converters
class ListConverter extends TypeConverter<List<String>, String> {
  const ListConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

@DriftDatabase(
    tables: [Products, Suppliers, Users, StockTransactions, Lots],
    daos: [ProductDao, SupplierDao, UserDao, StockTransactionDao, LotDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await m.addColumn(users, users.password);
          }
          if (from < 4) {
            await m.createTable(lots);
            await m.addColumn(stockTransactions, stockTransactions.lotId);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// DAOs
@DriftAccessor(tables: [Products, Lots])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(AppDatabase db) : super(db);

  Stream<List<Product>> watchAllProducts({String? searchQuery, bool lowStock = false}) {
    var query = select(products);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((p) => p.name.like('%$searchQuery%') | p.sku.like('%$searchQuery%'));
    }

    if (lowStock) {
      query.where((p) => p.minimumStockThreshold.isNotNull() & p.stockQuantity.isSmallerOrEqual(p.minimumStockThreshold));
    }

    return query.watch();
  }

  Future<Product?> getProductById(String id) => (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
  Future<Product?> getProductByBarcode(String barcode) => (select(products)..where((p) => p.barcode.equals(barcode))).getSingleOrNull();
  Future<void> insertProduct(Product product) => into(products).insert(product);
  Future<bool> updateProduct(Product product) => update(products).replace(product);
  Future<int> deleteProduct(String id) => (delete(products)..where((p) => p.id.equals(id))).go();
  Future<List<Product>> getUnsyncedProducts() => (select(products)..where((p) => p.syncStatus.isNotValue(SyncStatus.synced.index))).get();

  Stream<List<Product>> watchProductsBySupplier(String supplierId) {
    return (select(products)..where((p) => p.supplierId.equals(supplierId))).watch();
  }

  Future<int> getProductCount() async {
    final countExp = products.id.count();
    final query = selectOnly(products)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<int> getLowStockCount() async {
    final countExp = products.id.count(filter: products.stockQuantity.isSmallerOrEqual(products.minimumStockThreshold) & products.minimumStockThreshold.isNotNull());
    final query = selectOnly(products)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<List<Product>> getTopStockedProducts(int limit) {
    return (select(products)
          ..orderBy([(p) => OrderingTerm.desc(p.stockQuantity)])
          ..limit(limit))
        .get();
  }

  Future<List<Product>> getAllProducts() => select(products).get();
}

@DriftAccessor(tables: [Lots])
class LotDao extends DatabaseAccessor<AppDatabase> with _$LotDaoMixin {
  LotDao(AppDatabase db) : super(db);

  Stream<List<Lot>> watchLotsForProduct(String productId) {
    return (select(lots)..where((l) => l.productId.equals(productId))).watch();
  }

  Future<void> insertLot(Lot lot) => into(lots).insert(lot);
  Future<bool> updateLot(Lot lot) => update(lots).replace(lot);
  Future<int> deleteLot(String id) => (delete(lots)..where((l) => l.id.equals(id))).go();
}


@DriftAccessor(tables: [Suppliers])
class SupplierDao extends DatabaseAccessor<AppDatabase> with _$SupplierDaoMixin {
  SupplierDao(AppDatabase db) : super(db);

  Stream<List<Supplier>> watchAllSuppliers({String? searchQuery}) {
    var query = select(suppliers);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((s) => s.name.like('%$searchQuery%'));
    }
    return query.watch();
  }

  Future<Supplier?> getSupplierById(String id) => (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
  Future<void> insertSupplier(Supplier supplier) => into(suppliers).insert(supplier);
  Future<bool> updateSupplier(Supplier supplier) => update(suppliers).replace(supplier);
  Future<int> deleteSupplier(String id) => (delete(suppliers)..where((s) => s.id.equals(id))).go();
}

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  Future<User?> getUserByEmail(String email) =>
      (select(users)..where((u) => u.email.equals(email))).getSingleOrNull();
  Future<void> insertUser(UsersCompanion user) => into(users).insert(user);
}

@DriftAccessor(tables: [StockTransactions])
class StockTransactionDao extends DatabaseAccessor<AppDatabase>
    with _$StockTransactionDaoMixin {
  StockTransactionDao(AppDatabase db) : super(db);

  Stream<List<StockTransaction>> watchTransactionsForProduct(String productId) {
    return (select(stockTransactions)..where((t) => t.productId.equals(productId)))
        .watch();
  }

  Stream<List<StockTransaction>> watchRecentTransactions(int limit) {
    return (select(stockTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch();
  }

  Future<void> insertTransaction(StockTransaction transaction) =>
      into(stockTransactions).insert(transaction);
}