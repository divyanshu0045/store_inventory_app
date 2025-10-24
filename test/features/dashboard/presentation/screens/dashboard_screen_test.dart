import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/data/datasources/local/database_provider.dart';
import 'package:inventory_management_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:inventory_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';

import '../../../../test_utils.dart';

void main() {
  late db.AppDatabase testDatabase;

  // Create a fresh in-memory database for each test.
  setUp(() {
    testDatabase = createTestDatabase();
  });

  // Close the database after each test.
  tearDown(() async {
    await testDatabase.close();
  });

  testWidgets('DashboardScreen shows loading indicators when providers are loading', (tester) async {
    // We use fakeAsync to control timers and prevent pending timer errors.
    await fakeAsync((async) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the database provider to use the in-memory version.
            databaseProvider.overrideWithValue(testDatabase),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // The DashboardScreen has 5 providers that will be in a loading state initially.
      expect(find.byType(CircularProgressIndicator), findsNWidgets(5));

      // Flush any pending timers from stream cleanup to prevent test failure.
      async.flushTimers();
    })(tester);
  });

  testWidgets('DashboardScreen shows data when all providers return data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the database provider itself for any underlying dependencies
          databaseProvider.overrideWithValue(testDatabase),
          // Override the specific providers with mock data
          productCountProvider.overrideWith((ref) => 10),
          lowStockCountProvider.overrideWith((ref) => 2),
          lowStockProductsProvider.overrideWith((ref) => Stream.value([])),
          topStockedProductsProvider.overrideWith((ref) => Future.value([])),
          recentTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for the providers to emit their values
    await tester.pumpAndSettle();

    // Assert that the data is displayed
    expect(find.text('10'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('No recent activity.'), findsOneWidget);

    // Assert that no loading indicators are present
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('DashboardScreen shows error UI when providers fail', (tester) async {
    final error = Exception('Failed to load');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the database provider itself for any underlying dependencies
          databaseProvider.overrideWithValue(testDatabase),
          // Override the specific providers with error states
          productCountProvider.overrideWith((ref) => throw error),
          lowStockCountProvider.overrideWith((ref) => throw error),
          lowStockProductsProvider.overrideWith((ref) => Stream.error(error)),
          topStockedProductsProvider.overrideWith((ref) => Future.error(error)),
          recentTransactionsStreamProvider.overrideWith((ref) => Stream.error(error)),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for the providers to emit their error states
    await tester.pumpAndSettle();

    // Assert that the error UI is shown for the providers that have it
    expect(find.text('Error'), findsNWidgets(2)); // For the two summary cards
    expect(find.text('Could not load activity.'), findsOneWidget);

    // Assert that no loading indicators are present
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}