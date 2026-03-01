import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_session_providers.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../l10n/app_localizations.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final session = ref.watch(authSessionProvider);
    final loggedIn = session != null;
    final isAdmin = ref.watch(isAdminProvider);
    final t = S.of(context)!;

    // Build destinations list — admin tab only if admin
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: t.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.grid_view_outlined),
        selectedIcon: const Icon(Icons.grid_view),
        label: t.navCatalog,
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: cartState.totalItems > 0,
          label: Text('${cartState.totalItems}'),
          child: const Icon(Icons.shopping_bag_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: cartState.totalItems > 0,
          label: Text('${cartState.totalItems}'),
          child: const Icon(Icons.shopping_bag),
        ),
        label: t.navCart,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: loggedIn ? t.navAccount : t.navLogin,
      ),
      if (isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: const Icon(Icons.admin_panel_settings),
          label: t.navAdmin,
        ),
    ];

    // Map visual index to branch index
    // Branches: 0=Home, 1=Catalogo, 2=Carrito, 3=Cuenta, 4=Admin
    // When admin is hidden, visual indices 0-3 map directly.
    // When admin is visible, visual index 4 maps to branch 4.
    final currentBranch = navigationShell.currentIndex;
    final visualIndex = isAdmin
        ? currentBranch
        : (currentBranch > 3 ? 3 : currentBranch);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 0.5),
          NavigationBar(
            selectedIndex: visualIndex.clamp(0, destinations.length - 1),
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: destinations,
          ),
        ],
      ),
    );
  }
}
