import 'package:drift/native.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart';

/// Creates an in-memory version of the [AppDatabase] for testing purposes.
///
/// This utility provides a clean, isolated database instance for each test,
/// ensuring that tests do not interfere with each other.
AppDatabase createTestDatabase() {
  final executor = NativeDatabase.memory();
  final database = AppDatabase(executor);
  return database;
}