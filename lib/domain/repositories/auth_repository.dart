import 'package:inventory_management_app/data/datasources/local/database.dart' as db;

abstract class AuthRepository {
  Future<db.User?> login(String email, String password);

  Future<void> signup(String email, String password, db.UserRole role);

  Future<void> logout();

  Stream<db.User?> get currentUser;
}