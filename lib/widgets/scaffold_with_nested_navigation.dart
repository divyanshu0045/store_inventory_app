import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/core/services/service_providers.dart';
import 'package:inventory_management_app/widgets/network_status_banner.dart';

class ScaffoldWithNestedNavigation extends ConsumerWidget {
  final List<String> pageTitles = const [
    'Dashboard',
    'Inventory',
    'Suppliers',
    'Reports',
    'Settings'
  ];

  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(
            key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[navigationShell.currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(syncServiceProvider).sync();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const NetworkStatusBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(label: 'Dashboard', icon: Icon(Icons.dashboard)),
          NavigationDestination(label: 'Inventory', icon: Icon(Icons.inventory)),
          NavigationDestination(label: 'Suppliers', icon: Icon(Icons.people)),
          NavigationDestination(label: 'Reports', icon: Icon(Icons.bar_chart)),
          NavigationDestination(label: 'Settings', icon: Icon(Icons.settings)),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}