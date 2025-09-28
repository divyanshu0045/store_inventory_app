import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:inventory_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen shows loading indicators when providers are loading', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Initially, providers are in loading state
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });

  testWidgets('DashboardScreen shows data when providers return data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productCountProvider.overrideWith((ref) => 10),
          lowStockCountProvider.overrideWith((ref) => 2),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for the providers to emit their values
    await tester.pump();

    expect(find.text('10'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('DashboardScreen shows error message when providers fail', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productCountProvider.overrideWith((ref) => throw Exception('Failed to load')),
          lowStockCountProvider.overrideWith((ref) => throw Exception('Failed to load')),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for the providers to emit their error states
    await tester.pump();

    expect(find.text('Error'), findsNWidgets(2));
  });
}