import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/core/navigation/app_router.dart';
import 'package:inventory_management_app/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    // Watch the theme notifier provider to get the current theme mode.
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Inventory Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Use the themeMode from the provider.
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}