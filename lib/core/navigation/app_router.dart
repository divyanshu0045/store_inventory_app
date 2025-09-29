import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:inventory_management_app/features/auth/presentation/screens/login_screen.dart';
import 'package:inventory_management_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:inventory_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/add_stock_transaction_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/edit_product_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:inventory_management_app/features/inventory/presentation/screens/scanner_screen.dart';
import 'package:inventory_management_app/features/reports/presentation/screens/reports_screen.dart';
import 'package:inventory_management_app/features/search/presentation/screens/global_search_screen.dart';
import 'package:inventory_management_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/add_supplier_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/edit_supplier_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/supplier_detail_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/suppliers_screen.dart';
import 'package:inventory_management_app/widgets/scaffold_with_nested_navigation.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  // Listen to the auth state for redirection logic
  final authState = ref.watch(authStateStreamProvider);
  // Get the auth repository to access the raw stream for the refreshListenable
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    // The refreshListenable needs a stream, not the AsyncValue.
    // We get it from the repository directly.
    refreshListenable: GoRouterRefreshStream(authRepository.currentUser),
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authState.asData?.value != null;
      final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }
      if (loggedIn && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                pageBuilder: (context, state) => const NoTransitionPage(child: InventoryScreen()),
                routes: [
                  GoRoute(
                    path: 'product/:productId',
                    builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['productId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/suppliers',
                pageBuilder: (context, state) => const NoTransitionPage(child: SuppliersScreen()),
                routes: [
                  GoRoute(
                    path: 'supplier/:supplierId',
                    builder: (context, state) => SupplierDetailScreen(supplierId: state.pathParameters['supplierId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/add-product',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/edit-product',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final product = state.extra as db.Product;
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/add-stock-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final product = state.extra as db.Product;
          return AddStockTransactionScreen(product: product);
        },
      ),
      GoRoute(
        path: '/scanner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/add-supplier',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddSupplierScreen(),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/edit-supplier',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final supplier = state.extra as db.Supplier;
          return EditSupplierScreen(supplier: supplier);
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}