import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/domain/usecases/login_user.dart';
import 'package:inventory_management_app/domain/usecases/signup_user.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final SignupUser _signupUser;

  AuthNotifier(this._loginUser, this._signupUser)
      : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _loginUser(email, password);
      if (user != null) {
        state = AuthState.authenticated(user: user);
      } else {
        state = const AuthState.error('Invalid credentials.');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signup(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _signupUser(email, password);
      if (user != null) {
        state = AuthState.authenticated(user: user);
      } else {
        // This case should ideally not happen if signup throws an error on failure
        state = const AuthState.error('Signup failed for an unknown reason.');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() {
    state = const AuthState.unauthenticated();
  }
}