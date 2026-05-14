import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';

/// Modelo del estado de configuración de la app
class SettingsState {
  final bool mostrarMercado;
  final bool mostrarPortafolio;
  final bool mostrarHistorial;
  final bool autoRefresh;
  final int intervaloRefresh; // en segundos

  const SettingsState({
    this.mostrarMercado = true,
    this.mostrarPortafolio = true,
    this.mostrarHistorial = true,
    this.autoRefresh = true,
    this.intervaloRefresh = 30,
  });

  SettingsState copyWith({
    bool? mostrarMercado,
    bool? mostrarPortafolio,
    bool? mostrarHistorial,
    bool? autoRefresh,
    int? intervaloRefresh,
  }) {
    return SettingsState(
      mostrarMercado: mostrarMercado ?? this.mostrarMercado,
      mostrarPortafolio: mostrarPortafolio ?? this.mostrarPortafolio,
      mostrarHistorial: mostrarHistorial ?? this.mostrarHistorial,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      intervaloRefresh: intervaloRefresh ?? this.intervaloRefresh,
    );
  }

  Map<String, dynamic> toJson() => {
    'mostrarMercado': mostrarMercado,
    'mostrarPortafolio': mostrarPortafolio,
    'mostrarHistorial': mostrarHistorial,
    'autoRefresh': autoRefresh,
    'intervaloRefresh': intervaloRefresh,
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      mostrarMercado: json['mostrarMercado'] as bool? ?? true,
      mostrarPortafolio: json['mostrarPortafolio'] as bool? ?? true,
      mostrarHistorial: json['mostrarHistorial'] as bool? ?? true,
      autoRefresh: json['autoRefresh'] as bool? ?? true,
      intervaloRefresh: json['intervaloRefresh'] as int? ?? 30,
    );
  }
}

/// Provider del estado de configuración
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _cargarConfiguracion();
  }

  /// Carga la configuración guardada del almacenamiento local
  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.settingsKey);
    if (data != null) {
      state = SettingsState.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    }
  }

  /// Guarda la configuración actual en el almacenamiento
  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.settingsKey, jsonEncode(state.toJson()));
  }

  void toggleMercado(bool valor) {
    state = state.copyWith(mostrarMercado: valor);
    _guardar();
  }

  void togglePortafolio(bool valor) {
    state = state.copyWith(mostrarPortafolio: valor);
    _guardar();
  }

  void toggleHistorial(bool valor) {
    state = state.copyWith(mostrarHistorial: valor);
    _guardar();
  }

  void toggleAutoRefresh(bool valor) {
    state = state.copyWith(autoRefresh: valor);
    _guardar();
  }

  void cambiarIntervalo(int segundos) {
    state = state.copyWith(intervaloRefresh: segundos);
    _guardar();
  }
}

/// Pantalla de configuración de la aplicación.
/// Permite ocultar/mostrar secciones y controlar el auto-refresco.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ───────────────────────────────────
          Text(
            'Configuración',
            style: AppTypography.h2.copyWith(color: AppColors.onSurface),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'Personaliza tu experiencia en ChinChin Exchange',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          // ── Sección de visibilidad ──────────────────────
          _buildSectionTitle('Secciones visibles', Icons.visibility_rounded, 0),
          const SizedBox(height: 12),

          _buildToggle(
            ref: ref,
            titulo: 'Mercado',
            descripcion: 'Mostrar la tabla de criptomonedas disponibles',
            icono: Icons.show_chart_rounded,
            valor: settings.mostrarMercado,
            onChanged: (v) => ref.read(settingsProvider.notifier).toggleMercado(v),
            index: 1,
          ),

          _buildToggle(
            ref: ref,
            titulo: 'Portafolio',
            descripcion: 'Mostrar el resumen de tus activos',
            icono: Icons.account_balance_wallet_rounded,
            valor: settings.mostrarPortafolio,
            onChanged: (v) => ref.read(settingsProvider.notifier).togglePortafolio(v),
            index: 2,
          ),

          _buildToggle(
            ref: ref,
            titulo: 'Historial',
            descripcion: 'Mostrar el historial de transacciones',
            icono: Icons.history_rounded,
            valor: settings.mostrarHistorial,
            onChanged: (v) => ref.read(settingsProvider.notifier).toggleHistorial(v),
            index: 3,
          ),

          const SizedBox(height: 28),

          // ── Sección de actualización ─────────────────────
          _buildSectionTitle('Actualización de datos', Icons.refresh_rounded, 4),
          const SizedBox(height: 12),

          _buildToggle(
            ref: ref,
            titulo: 'Auto-refresco',
            descripcion: 'Actualizar precios automáticamente',
            icono: Icons.autorenew_rounded,
            valor: settings.autoRefresh,
            onChanged: (v) => ref.read(settingsProvider.notifier).toggleAutoRefresh(v),
            index: 5,
          ),

          if (settings.autoRefresh) ...[
            const SizedBox(height: 12),
            _buildIntervalSelector(ref, settings),
          ],

          const SizedBox(height: 28),

          // ── Información de la app ────────────────────────
          _buildSectionTitle('Acerca de', Icons.info_outline_rounded, 6),
          const SizedBox(height: 12),

          GlassmorphicCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.currency_exchange_rounded,
                        color: AppColors.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: AppTypography.h4.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Versión ${AppConstants.appVersion}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Prueba técnica de desarrollo frontend para Chinchin. '
                  'Aplicación de intercambio de criptomonedas con datos '
                  'en tiempo real de la API de Binance.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip('Flutter', Icons.flutter_dash),
                    const SizedBox(width: 8),
                    _buildInfoChip('Riverpod', Icons.data_object_rounded),
                    const SizedBox(width: 8),
                    _buildInfoChip('Binance API', Icons.api_rounded),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.05, end: 0, delay: 400.ms),
        ],
      ),
    );
  }

  /// Título de sección con icono y animación
  Widget _buildSectionTitle(String titulo, IconData icono, int index) {
    return Row(
      children: [
        Icon(icono, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: AppTypography.h4.copyWith(color: AppColors.onSurface),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: (100 + index * 50).ms, duration: 400.ms);
  }

  /// Toggle switch con tarjeta glassmorphic
  Widget _buildToggle({
    required WidgetRef ref,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required bool valor,
    required ValueChanged<bool> onChanged,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icono,
              color: valor ? AppColors.primary : AppColors.onSurfaceMuted,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    descripcion,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: valor,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.onSurfaceMuted,
              inactiveTrackColor: AppColors.surfaceElevated,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 + index * 60).ms, duration: 400.ms)
        .slideX(begin: 0.05, end: 0, delay: (100 + index * 60).ms);
  }

  /// Selector de intervalo de actualización con chips
  Widget _buildIntervalSelector(WidgetRef ref, SettingsState settings) {
    final opciones = [15, 30, 60, 120];

    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intervalo de actualización',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: opciones.map((seg) {
              final estaActivo = settings.intervaloRefresh == seg;
              final etiqueta = seg < 60 ? '${seg}s' : '${seg ~/ 60}min';

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    ref.read(settingsProvider.notifier).cambiarIntervalo(seg);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: estaActivo
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: estaActivo
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      etiqueta,
                      style: AppTypography.labelMedium.copyWith(
                        color: estaActivo
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight: estaActivo
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 350.ms, duration: 400.ms);
  }

  /// Chip de información con icono
  Widget _buildInfoChip(String texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(
            texto,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
