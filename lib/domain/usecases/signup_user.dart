import 'package:inventory_management_app/domain/entities/user.dart';
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<User?> call(String email, String password) {
    return repository.signup(email, password);
  }
}