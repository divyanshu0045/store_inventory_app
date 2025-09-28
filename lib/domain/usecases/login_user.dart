import 'package:inventory_management_app/domain/entities/user.dart';
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<User?> call(String email, String password) {
    return repository.login(email, password);
  }
}