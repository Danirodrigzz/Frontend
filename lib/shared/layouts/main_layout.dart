import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Layout principal con navegación superior horizontal.
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final rutaActual = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Barra de navegación superior ─────────────────────
          _buildTopNav(context, authState, rutaActual, ref),

          // ── Contenido principal ──────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Barra superior con logo, tabs de navegación y perfil
  Widget _buildTopNav(BuildContext context, AuthState authState, String rutaActual, WidgetRef ref) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceHeader,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
      ),
      child: RepaintBoundary(
        child: Row(
          children: [
            // Logo ChinChin (Izquierda)
            SizedBox(
              width: 180,
              child: GestureDetector(
                onTap: () => context.go('/'),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 28,
                  fit: BoxFit.contain,
                  color: AppColors.primary,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),

            const Spacer(),

            // ── Tabs de navegación con SEGUIMIENTO DE CURSOR (HOVER) ──
            _InteractiveTabs(rutaActual: rutaActual),

            const Spacer(),

            // Perfil / Auth (Derecha)
            SizedBox(
              width: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _statusIcons(),
                  const SizedBox(width: 12),
                  if (authState.usuario != null)
                    _userBadge(context, authState, ref)
                  else
                    _authButton(context, 'Ingresar', '/login', false),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad);
  }

  /// Iconos de estado (wifi, señal, etc.)
  Widget _statusIcons() {
    return Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
            boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.5), blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.wifi_rounded, color: AppColors.onSurfaceMuted, size: 16),
        const SizedBox(width: 6),
        const Icon(Icons.cell_tower_rounded, color: AppColors.onSurfaceMuted, size: 16),
        const SizedBox(width: 6),
        const Icon(Icons.notifications_none_rounded, color: AppColors.onSurfaceMuted, size: 16),
      ],
    );
  }

  /// Badge de usuario con dropdown
  Widget _userBadge(BuildContext context, AuthState authState, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.go('/settings'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Text(
                  authState.usuario!.nombre[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(authState.usuario!.nombre, style: const TextStyle(
              color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }

  /// Botón de autenticación
  Widget _authButton(BuildContext context, String label, String ruta, bool filled) {
    return InkWell(
      onTap: () => context.go(ruta),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Text(label, style: TextStyle(
          color: filled ? AppColors.onPrimary : AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        )),
      ),
    );
  }
}

/// Componente interno para gestionar el estado del hover en las pestañas
class _InteractiveTabs extends StatefulWidget {
  final String rutaActual;
  const _InteractiveTabs({required this.rutaActual});

  @override
  State<_InteractiveTabs> createState() => _InteractiveTabsState();
}

class _InteractiveTabsState extends State<_InteractiveTabs> {
  int? _hoveredIndex;
  static const double tabWidth = 125.0;
  final List<String> _rutas = ['/', '/portfolio', '/exchange', '/history', '/settings'];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _rutas.indexOf(widget.rutaActual);
    final displayIndex = _hoveredIndex ?? activeIndex;

    return MouseRegion(
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: SizedBox(
        width: tabWidth * 5,
        height: 52,
        child: Stack(
          children: [
            // El Indicador Magnético (capa inferior) que sigue al cursor
            if (displayIndex != -1)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 650), // Más lento y elegante
                curve: Curves.easeInOutQuart, // Curva más suave
                bottom: 0,
                left: displayIndex * tabWidth + (tabWidth - 45) / 2,
                child: Container(
                  height: 3,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

            // Los Tabs (capa superior detectora)
            Row(
              children: [
                _buildTab(0, 'Resumen', Icons.grid_view_rounded),
                _buildTab(1, 'Billetera', Icons.account_balance_wallet_rounded),
                _buildTab(2, 'Intercambio', Icons.swap_horizontal_circle_rounded),
                _buildTab(3, 'Historial', Icons.history_rounded),
                _buildTab(4, 'Ajustes', Icons.settings_suggest_rounded),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic).fadeIn();
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final activo = widget.rutaActual == _rutas[index];
    final isHovering = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      child: InkWell(
        onTap: () => context.go(_rutas[index]),
        hoverColor: Colors.white.withValues(alpha: 0.03),
        child: Container(
          height: 52,
          width: tabWidth,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 16, 
                color: (activo || isHovering) ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.6)
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: (activo || isHovering) ? Colors.white : AppColors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: (activo || isHovering) ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
