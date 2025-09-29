import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _authRepository.login(email, password);
      if (user != null) {
        state = const AuthState.success();
      } else {
        state = const AuthState.error('Invalid credentials.');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signup(String email, String password, {db.UserRole role = db.UserRole.staff}) async {
    state = const AuthState.loading();
    try {
      await _authRepository.signup(email, password, role);
      state = const AuthState.success();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.initial();
  }
}