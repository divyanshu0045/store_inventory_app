import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/auth_repository_impl.dart';
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';
import 'package:inventory_management_app/domain/usecases/login_user.dart';
import 'package:inventory_management_app/domain/usecases/signup_user.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_state.dart';

// 1. Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dao = ref.watch(userDaoProvider);
  return AuthRepositoryImpl(dao);
});

// 2. Use Case Provider
final loginUserProvider = Provider<LoginUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUser(repository);
});

final signupUserProvider = Provider<SignupUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUser(repository);
});

// 3. State Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUser = ref.watch(loginUserProvider);
  final signupUser = ref.watch(signupUserProvider);
  return AuthNotifier(loginUser, signupUser);
});

// 4. Provider to expose the current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(authenticated: (user) => user);
});