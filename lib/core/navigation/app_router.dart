import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:inventory_management_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/add_supplier_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/edit_supplier_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/supplier_detail_screen.dart';
import 'package:inventory_management_app/features/suppliers/presentation/screens/suppliers_screen.dart';
import 'package:inventory_management_app/widgets/scaffold_with_nested_navigation.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    routes: [
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
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/edit-product',
        builder: (context, state) {
          final product = state.extra as domain.Product;
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/add-stock-transaction',
        builder: (context, state) {
          final product = state.extra as domain.Product;
          return AddStockTransactionScreen(product: product);
        },
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/add-supplier',
        builder: (context, state) => const AddSupplierScreen(),
      ),
      GoRoute(
        path: '/edit-supplier',
        builder: (context, state) {
          final supplier = state.extra as domain.Supplier;
          return EditSupplierScreen(supplier: supplier);
        },
      ),
      StatefulNavigationShell.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: '/inventory',
                  pageBuilder: (context, state) => const NoTransitionPage(
                        child: InventoryScreen(),
                      ),
                  routes: [
                    GoRoute(
                      path: 'product/:productId',
                      builder: (context, state) {
                        final productId = state.pathParameters['productId']!;
                        return ProductDetailScreen(productId: productId);
                      },
                    ),
                  ]),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: '/suppliers',
                  pageBuilder: (context, state) => const NoTransitionPage(
                        child: SuppliersScreen(),
                      ),
                  routes: [
                    GoRoute(
                      path: 'supplier/:supplierId',
                      builder: (context, state) {
                        final supplierId = state.pathParameters['supplierId']!;
                        return SupplierDetailScreen(supplierId: supplierId);
                      },
                    ),
                  ]),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ReportsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});