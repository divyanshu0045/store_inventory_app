import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/domain/entities/user.dart' as domain_user;
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserDao _userDao;

  AuthRepositoryImpl(this._userDao);

  @override
  Future<domain_user.User?> login(String email, String password) async {
    final user = await _userDao.getUserByEmail(email);
    if (user != null && user.password == password) {
      // In a real app, use a secure password hashing and comparison algorithm
      return _mapUserToDomainUser(user);
    }
    return null;
  }

  @override
  Future<domain_user.User?> signup(String email, String password) async {
    final existingUser = await _userDao.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('A user with this email already exists.');
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary unique ID
      email: email,
      password: password, // In a real app, this would be hashed
      role: domain_user.UserRole.staff.index,
    );

    await _userDao.insertUser(newUser);
    return _mapUserToDomainUser(newUser);
  }

  @override
  Future<void> logout() async {
    // In a real app, this would clear the session token.
    return Future.value();
  }

  domain_user.User _mapUserToDomainUser(User user) {
    return domain_user.User(
      id: user.id,
      email: user.email,
      role: domain_user.UserRole.values[user.role],
    );
  }
}