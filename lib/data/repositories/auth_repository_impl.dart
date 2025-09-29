import 'dart:async';
import 'package:drift/drift.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  final db.UserDao _userDao;
  final _currentUserController = BehaviorSubject<db.User?>.seeded(null);

  AuthRepositoryImpl(this._userDao);

  @override
  Stream<db.User?> get currentUser => _currentUserController.stream;

  @override
  Future<db.User?> login(String email, String password) async {
    final user = await _userDao.getUserByEmail(email);
    // In a real app, you'd use a secure password hashing and verification library.
    if (user != null && user.password == password) {
      _currentUserController.add(user);
      return user;
    }
    _currentUserController.add(null);
    return null;
  }

  @override
  Future<void> signup(String email, String password, db.UserRole role) async {
    final existingUser = await _userDao.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('A user with this email already exists.');
    }

    final newUserCompanion = db.UsersCompanion(
      id: Value(const Uuid().v4()),
      email: Value(email),
      // Passwords should always be hashed before storing.
      password: Value(password),
      role: Value(role.index),
    );

    await _userDao.insertUser(newUserCompanion);
    // After signup, log the user in automatically.
    await login(email, password);
  }

  @override
  Future<void> logout() async {
    _currentUserController.add(null);
  }
}