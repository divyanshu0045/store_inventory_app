import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/data/repositories/auth_repository_impl.dart';
import 'package:inventory_management_app/domain/repositories/auth_repository.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:inventory_management_app/features/auth/presentation/providers/auth_state.dart';

// 1. Repository Provider (provides the abstraction)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dao = ref.watch(userDaoProvider);
  return AuthRepositoryImpl(dao);
});

// 2. Auth State Stream Provider (the single source of truth for auth status)
final authStateStreamProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

// 3. State Notifier Provider (for handling auth actions like login/logout)
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});