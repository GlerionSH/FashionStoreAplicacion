import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/providers/auth_session_providers.dart';
import '../../features/auth/presentation/screens/account_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_success_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/profiles/domain/entities/profile.dart';
import '../../features/admin/presentation/screens/admin_home_screen.dart';
import '../../features/admin/presentation/screens/admin_flash_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_order_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_product_create_screen.dart';
import '../../features/admin/presentation/screens/admin_product_edit_screen.dart';
import '../../features/admin/presentation/screens/admin_returns_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/admin_coupons_screen.dart';
import '../../features/admin/presentation/screens/admin_shipments_screen.dart';
import '../../features/admin/presentation/screens/admin_cancellations_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_return_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_support_screen.dart';
import '../../features/diagnostics/presentation/screens/connectivity_diagnostics_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<Session?>(authSessionProvider, (_, _) {
      notifyListeners();
    });
    ref.listen<AsyncValue<Profile?>>(currentProfileProvider, (_, _) {
      notifyListeners();
    });
  }
}

// ---------------------------------------------------------------------------
// Transition helpers
// ---------------------------------------------------------------------------
CustomTransitionPage<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);
  final profileAv = ref.watch(currentProfileProvider);
  final isAdmin = ref.watch(isAdminProvider);

  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final loggedIn = session != null;

      final loc = state.matchedLocation;
      final isAdminPanel =
          loc == '/admin-panel' || loc.startsWith('/admin-panel/');
      final isAdminLogin = loc == '/admin/login';
      final isLogin = loc == '/login';
      final isRegister = loc == '/register';

      // Admin panel routes require login + admin role
      if (isAdminPanel && !loggedIn) {
        return '/admin/login';
      }
      if (isAdminPanel && loggedIn) {
        if (profileAv.isLoading) return null;
        if (!isAdmin) return '/';
      }

      // Admin login redirect
      if (isAdminLogin && loggedIn) {
        if (profileAv.isLoading) return null;
        return isAdmin ? '/admin-panel' : '/';
      }

      // Regular login redirect
      if (isLogin && loggedIn) {
        return '/';
      }

      // Register redirect (allow when not logged in)
      if (isRegister && loggedIn) {
        return '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          // 0 — Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          // 1 — Catalogo
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/productos',
              builder: (context, state) => const ProductsScreen(),
              routes: [
                GoRoute(
                  path: ':slug',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeSlide(
                    state,
                    ProductDetailScreen(
                      slug: state.pathParameters['slug'] ?? '',
                    ),
                  ),
                ),
              ],
            ),
          ]),
          // 2 — Carrito
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/carrito',
              builder: (context, state) => const CartScreen(),
            ),
          ]),
          // 3 — Cuenta
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/cuenta',
              builder: (context, state) => const AccountScreen(),
              routes: [
                GoRoute(
                  path: 'pedidos',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fade(state, const OrdersScreen()),
                  routes: [
                    GoRoute(
                      path: ':id',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => _fade(
                        state,
                        OrderDetailScreen(
                          orderId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'soporte',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _fade(state, const SupportScreen()),
                ),
              ],
            ),
          ]),
          // 4 — Admin (tab only visible when isAdmin)
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/admin-panel',
              builder: (context, state) => const AdminHomeScreen(),
            ),
          ]),
        ],
      ),

      // ── Admin sub-routes (pushed over root navigator) ──
      GoRoute(
        path: '/admin-panel/productos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminProductsScreen(),
        routes: [
          GoRoute(
            path: 'nuevo',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) =>
                const AdminProductCreateScreen(),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => AdminProductEditScreen(
              productId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-panel/pedidos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminOrdersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => AdminOrderDetailScreen(
              orderId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-panel/devoluciones',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminReturnsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => AdminReturnDetailScreen(
              returnId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-panel/flash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminFlashScreen(),
      ),
      GoRoute(
        path: '/admin-panel/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin-panel/cupones',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminCouponsScreen(),
      ),
      GoRoute(
        path: '/admin-panel/envios',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminShipmentsScreen(),
      ),
      GoRoute(
        path: '/admin-panel/cancelaciones',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminCancellationsScreen(),
      ),
      GoRoute(
        path: '/admin-panel/usuarios',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin-panel/soporte',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminSupportScreen(),
      ),

      // ── Other top-level routes ──
      GoRoute(
        path: '/checkout/success',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fade(
          state,
          CheckoutSuccessScreen(
            sessionId: state.uri.queryParameters['session_id'],
            orderId: state.uri.queryParameters['order_id'],
          ),
        ),
      ),
      GoRoute(
        path: '/diagnostics',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _fade(state, const ConnectivityDiagnosticsScreen()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _fade(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _fade(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/admin/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminLoginScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Color(0xFF9E9E9E),
              ),
              const SizedBox(height: 24),
              const Text(
                'Página no encontrada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('IR A INICIO'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF111111)),
                  ),
                  child: const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(color: Color(0xFF111111)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
