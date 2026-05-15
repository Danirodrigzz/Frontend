import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.settingsKey);
    if (data != null) {
      state = SettingsState.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    }
  }

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

/// Pantalla de configuración mejorada con estética de dashboard premium.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final isMobile = MediaQuery.of(context).size.width < 1200;

    return Stack(
      children: [
        _buildBackgroundOrbs(),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // El título y el estado del sistema
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panel de Configuración',
                          style: AppTypography.h3.copyWith(color: AppColors.onSurface, fontSize: isMobile ? 18 : 22),
                        ),
                        Text(
                          'Personaliza tu interfaz y preferencias del sistema',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) _statusRow('SISTEMA', 'ESTABLE', AppColors.success),
                ],
              ),
              const SizedBox(height: 20),

              if (isMobile)
                Column(
                  children: [
                    _panel(
                      header: 'INFORMACIÓN',
                      icon: Icons.info_outline_rounded,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SvgPicture.asset(
                                      'assets/images/logo-2.svg',
                                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppConstants.appName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Versión ${AppConstants.appVersion}', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aplicación premium de intercambio de activos con datos sincronizados en tiempo real.',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, height: 1.5, fontSize: 10),
                            ),
                            const SizedBox(height: 16),
                            _buildTechChips(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      header: 'DISPOSITIVO',
                      icon: Icons.devices_rounded,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow('Almacenamiento', 'Local (SharedPrefs)', AppColors.onSurfaceVariant),
                            const SizedBox(height: 10),
                            _infoRow('Plataforma', 'Web (Flutter)', AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Lo que el usuario puede cambiar
                    _buildGroup(
                      title: 'VISIBILIDAD DE SECCIONES',
                      icon: Icons.visibility_rounded,
                      children: [
                        _buildToggle(
                          titulo: 'Panel de Mercado',
                          descripcion: 'Lista interactiva de precios actuales',
                          icono: Icons.analytics_outlined,
                          valor: settings.mostrarMercado,
                          onChanged: (v) => ref.read(settingsProvider.notifier).toggleMercado(v),
                        ),
                        _buildToggle(
                          titulo: 'Resumen de Portafolio',
                          descripcion: 'Visualización de tus activos totales',
                          icono: Icons.wallet_rounded,
                          valor: settings.mostrarPortafolio,
                          onChanged: (v) => ref.read(settingsProvider.notifier).togglePortafolio(v),
                        ),
                        _buildToggle(
                          titulo: 'Historial de Actividad',
                          descripcion: 'Registro de tus operaciones pasadas',
                          icono: Icons.history_edu_rounded,
                          valor: settings.mostrarHistorial,
                          onChanged: (v) => ref.read(settingsProvider.notifier).toggleHistorial(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGroup(
                      title: 'SINCRONIZACIÓN DE DATOS',
                      icon: Icons.sync_rounded,
                      children: [
                        _buildToggle(
                          titulo: 'Auto-refresco de Precios',
                          descripcion: 'Mantener datos actualizados vía API',
                          icono: Icons.bolt_rounded,
                          valor: settings.autoRefresh,
                          onChanged: (v) => ref.read(settingsProvider.notifier).toggleAutoRefresh(v),
                        ),
                        if (settings.autoRefresh) ...[
                          const Divider(height: 1, color: Colors.white10),
                          _buildIntervalSelector(ref, settings),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      header: 'SESIÓN',
                      icon: Icons.account_circle_outlined,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _mostrarConfirmacionCerrarSesion(context, ref),
                                icon: const Icon(Icons.logout_rounded, size: 16),
                                label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                                  foregroundColor: AppColors.error,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info de la app y del equipo
                    SizedBox(
                      width: 280,
                      child: Column(
                        children: [
                          _panel(
                            header: 'INFORMACIÓN',
                            icon: Icons.info_outline_rounded,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: SvgPicture.asset(
                                            'assets/images/logo-2.svg',
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppConstants.appName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                          Text('Versión ${AppConstants.appVersion}', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aplicación premium de intercambio de activos con datos sincronizados en tiempo real.',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, height: 1.5, fontSize: 10),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTechChips(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _panel(
                            header: 'DISPOSITIVO',
                            icon: Icons.devices_rounded,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _infoRow('Almacenamiento', 'Local (SharedPrefs)', AppColors.onSurfaceVariant),
                                  const SizedBox(height: 10),
                                  _infoRow('Plataforma', 'Web (Flutter)', AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _panel(
                            header: 'SESIÓN',
                            icon: Icons.account_circle_outlined,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _mostrarConfirmacionCerrarSesion(context, ref),
                                      icon: const Icon(Icons.logout_rounded, size: 16),
                                      label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                                        foregroundColor: AppColors.error,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Opciones para personalizar la vista
                    Expanded(
                      child: Column(
                        children: [
                          _buildGroup(
                            title: 'VISIBILIDAD DE SECCIONES',
                            icon: Icons.visibility_rounded,
                            children: [
                              _buildToggle(
                                titulo: 'Panel de Mercado',
                                descripcion: 'Lista interactiva de precios actuales',
                                icono: Icons.analytics_outlined,
                                valor: settings.mostrarMercado,
                                onChanged: (v) => ref.read(settingsProvider.notifier).toggleMercado(v),
                              ),
                              _buildToggle(
                                titulo: 'Resumen de Portafolio',
                                descripcion: 'Visualización de tus activos totales',
                                icono: Icons.wallet_rounded,
                                valor: settings.mostrarPortafolio,
                                onChanged: (v) => ref.read(settingsProvider.notifier).togglePortafolio(v),
                              ),
                              _buildToggle(
                                titulo: 'Historial de Actividad',
                                descripcion: 'Registro de tus operaciones pasadas',
                                icono: Icons.history_edu_rounded,
                                valor: settings.mostrarHistorial,
                                onChanged: (v) => ref.read(settingsProvider.notifier).toggleHistorial(v),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),

                          _buildGroup(
                            title: 'SINCRONIZACIÓN DE DATOS',
                            icon: Icons.sync_rounded,
                            children: [
                              _buildToggle(
                                titulo: 'Auto-refresco de Precios',
                                descripcion: 'Mantener datos actualizados vía API',
                                icono: Icons.bolt_rounded,
                                valor: settings.autoRefresh,
                                onChanged: (v) => ref.read(settingsProvider.notifier).toggleAutoRefresh(v),
                              ),
                              if (settings.autoRefresh) ...[
                                const Divider(height: 1, color: Colors.white10),
                                _buildIntervalSelector(ref, settings),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarConfirmacionCerrarSesion(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: GlassmorphicCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¿Cerrar Sesión?',
                    style: AppTypography.h4.copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¿Estás seguro de que deseas salir de la aplicación? Deberás ingresar tus credenciales nuevamente.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'CANCELAR',
                            style: TextStyle(
                              color: AppColors.onSurfaceMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await ref.read(authProvider.notifier).cerrarSesion();
                            if (context.mounted) context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'SALIR',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack),
    );
  }

  Widget _buildGroup({required String title, required IconData icon, required List<Widget> children}) {
    return GlassmorphicCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!valor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: valor ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: valor ? AppColors.primary : AppColors.onSurfaceMuted, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(descripcion, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted, fontSize: 10)),
                ],
              ),
            ),
            Switch(
              value: valor,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.onSurfaceMuted,
              inactiveTrackColor: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector(WidgetRef ref, SettingsState settings) {
    final opciones = [15, 30, 60, 120];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frecuencia de actualización', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            children: opciones.map((seg) {
              final estaActivo = settings.intervaloRefresh == seg;
              final etiqueta = seg < 60 ? '${seg}s' : '${seg ~/ 60}m';

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => ref.read(settingsProvider.notifier).cambiarIntervalo(seg),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: estaActivo ? AppColors.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: estaActivo ? AppColors.primary.withValues(alpha: 0.5) : Colors.white10),
                    ),
                    child: Text(
                      etiqueta,
                      style: TextStyle(color: estaActivo ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: estaActivo ? FontWeight.w900 : FontWeight.w600, fontSize: 11),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _miniChip('Flutter', Icons.flutter_dash),
        _miniChip('Riverpod', Icons.data_object),
        _miniChip('Binance', Icons.api),
      ],
    );
  }

  Widget _miniChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted)),
        Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 8, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _panel({required String header, required IconData icon, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03)),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 12),
                    const SizedBox(width: 8),
                    Text(header, style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(top: -50, left: -100, child: _orb(300, AppColors.primary.withValues(alpha: 0.08))),
        Positioned(bottom: -100, right: -50, child: _orb(250, const Color(0xFF6366F1).withValues(alpha: 0.06))),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.4), Colors.transparent]),
      ),
    );
  }
}
