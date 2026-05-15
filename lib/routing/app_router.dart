import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/market/presentation/pages/market_page.dart';
import '../features/market/presentation/pages/crypto_detail_page.dart';
import '../features/portfolio/presentation/pages/portfolio_page.dart';
import '../features/exchange/presentation/pages/exchange_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/layouts/main_layout.dart';

/// Configuración del enrutador de la aplicación con GoRouter.
/// Incluye guards de autenticación para proteger rutas privadas
/// y redirección automática según el estado de la sesión.

/// Provider del router que reacciona a cambios de autenticación
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    // Ruta inicial
    initialLocation: '/',

    // Redirección global basada en autenticación
    redirect: (context, state) {
      final estaAutenticado = authState.estaAutenticado;
      final estaCargando = authState.estaCargando;
      final rutaActual = state.uri.path;

      // Mientras verificamos la sesión, no redirigimos
      if (estaCargando) return null;

      // Rutas públicas (login y registro)
      final esRutaPublica = rutaActual == '/login' || rutaActual == '/register';

      // Si no está autenticado y no está en ruta pública, ir a login
      if (!estaAutenticado && !esRutaPublica) {
        return '/login';
      }

      // Si está autenticado y está en ruta pública, ir al home
      if (estaAutenticado && esRutaPublica) {
        return '/';
      }

      return null; // No redirigir
    },

    // Definición de las rutas
    routes: [
      // Rutas públicas (sin layout)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Rutas protegidas (con layout principal)
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Mercado (home)
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MarketPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Detalle de criptomoneda
          GoRoute(
            path: '/crypto/:symbol',
            pageBuilder: (context, state) {
              final symbol = state.pathParameters['symbol'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: CryptoDetailPage(symbol: symbol),
                transitionsBuilder: _fadeTransition,
              );
            },
          ),

          // Portafolio
          GoRoute(
            path: '/portfolio',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PortfolioPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Intercambio
          GoRoute(
            path: '/exchange',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExchangePage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Historial
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HistoryPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Configuración
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

/// Transición personalizada: fade suave entre páginas
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ),
    child: child,
  );
}
