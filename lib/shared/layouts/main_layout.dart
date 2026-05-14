import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final rutaActual = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopNav(context, authState, rutaActual, ref),
      body: Column(
        children: [
          _buildSubHeader(authState),
          Expanded(child: child),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopNav(BuildContext context, AuthState authState, String rutaActual, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            // Logo Turquesa
            GestureDetector(
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'CHINCHIN',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            
            // Items de Navegación
            _navItem(context, 'Mercado', '/', rutaActual == '/'),
            _navItem(context, 'Billetera', '/portfolio', rutaActual == '/portfolio'),
            _navItem(context, 'Intercambiar', '/exchange', rutaActual == '/exchange'),
            _navItem(context, 'Historial', '/history', rutaActual == '/history'),
            
            const Spacer(),
            
            // Usuario y Logout
            if (authState.usuario != null) ...[
              _userDropdown(context, authState, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, String route, bool active) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: active 
            ? Border(bottom: BorderSide(color: AppColors.primary, width: 2)) 
            : null,
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _userDropdown(BuildContext context, AuthState authState, WidgetRef ref) {
    return PopupMenuButton(
      offset: const Offset(0, 50),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surfaceVariant,
              child: Text(
                authState.usuario!.nombre[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(authState.usuario!.nombre, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface)),
              Text(authState.usuario!.email, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'settings',
          onTap: () => Future.microtask(() => context.go('/settings')),
          child: const Row(
            children: [
              Icon(Icons.settings_rounded, size: 18),
              SizedBox(width: 10),
              Text('Configuración'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          onTap: () async {
            await ref.read(authProvider.notifier).cerrarSesion();
            if (context.mounted) context.go('/login');
          },
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 10),
              Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeader(AuthState authState) {
    return Container(
      height: 40,
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.campaign_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            'Nuevo par PTR/USDT disponible ahora en ChinChin Exchange.',
            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            'VIP 0',
            style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
