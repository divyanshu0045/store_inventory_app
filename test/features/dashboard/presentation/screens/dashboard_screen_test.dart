import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:inventory_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;

void main() {
  testWidgets('DashboardScreen shows loading indicators when providers are loading', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // The DashboardScreen has 5 providers that will be in a loading state initially.
    // - productCountProvider (FutureProvider)
    // - lowStockCountProvider (FutureProvider)
    // - lowStockProductsProvider (StreamProvider)
    // - topStockedProductsProvider (FutureProvider)
    // - recentTransactionsStreamProvider (StreamProvider)
    // Each of these displays a CircularProgressIndicator in its loading state.
    expect(find.byType(CircularProgressIndicator), findsNWidgets(5));
  });

  testWidgets('DashboardScreen shows data when all providers return data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    // The other providers show a SizedBox.shrink() on error, so we don't expect visible error text for them.

    // Assert that no loading indicators are present
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}