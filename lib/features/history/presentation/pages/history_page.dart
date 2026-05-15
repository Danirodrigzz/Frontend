import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/animated_orbs_background.dart';
import '../../../market/presentation/providers/market_provider.dart';
import '../providers/history_provider.dart';

/// Pantalla del historial de transacciones mejorada con estética de dashboard.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(historyProvider.notifier).cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final market = ref.watch(marketProvider);

    final isMobile = MediaQuery.of(context).size.width < 1200;

    return Stack(
      children: [
        const AnimatedOrbsBackground(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la página
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de Actividad',
                          style: AppTypography.h3.copyWith(color: AppColors.onSurface, fontSize: isMobile ? 18 : 22),
                        ),
                        Text(
                          'Registro cronológico de tus intercambios realizados',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) _statusRow('ESTADO', 'ACTUALIZADO', AppColors.success),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            _panel(
                              header: 'RESUMEN',
                              icon: Icons.analytics_rounded,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _infoRow('Transacciones', historyState.transacciones.length.toString(), AppColors.primary),
                                    const SizedBox(height: 12),
                                    _infoRow('Estado Red', 'Sincronizado', AppColors.success),
                                    const SizedBox(height: 12),
                                    _infoRow('Última Op', historyState.transacciones.isEmpty ? '-' : 'Hoy', AppColors.onSurface),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (historyState.transacciones.isEmpty)
                              SizedBox(height: 300, child: _buildEmptyState())
                            else
                              ...historyState.transacciones.asMap().entries.map(
                                (entry) => _buildTransactionItem(entry.value, entry.key),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                _panel(
                                  header: 'RESUMEN',
                                  icon: Icons.analytics_rounded,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        _infoRow('Transacciones', historyState.transacciones.length.toString(), AppColors.primary),
                                        const SizedBox(height: 12),
                                        _infoRow('Estado Red', 'Sincronizado', AppColors.success),
                                        const SizedBox(height: 12),
                                        _infoRow('Última Op', historyState.transacciones.isEmpty ? '-' : 'Hoy', AppColors.onSurface),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _panel(
                                  header: 'SEGURIDAD',
                                  icon: Icons.lock_outline_rounded,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Todas las transacciones están cifradas y almacenadas localmente.',
                                          style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted, fontSize: 9),
                                        ),
                                        const SizedBox(height: 10),
                                        _statusRow('Cifrado', 'AES-256', AppColors.onSurfaceVariant),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: historyState.transacciones.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    itemCount: historyState.transacciones.length,
                                    itemBuilder: (context, index) {
                                      final tx = historyState.transacciones[index];
                                      return _buildTransactionItem(tx, index);
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic tx, int index) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: [
            Row(
              children: [
                // De dónde sale la plata
                Expanded(child: _cryptoColumnCompact(tx.simboloOrigen, tx.cantidadOrigen, AppColors.error, true)),
                
                // El icono del medio
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20),
                  child: Column(
                    children: [
                      Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: isMobile ? 20 : 24),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'INTERCAMBIO',
                          style: TextStyle(color: AppColors.primary, fontSize: 7, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),

                // A qué moneda se cambió
                Expanded(child: _cryptoColumnCompact(tx.simboloDestino, tx.cantidadDestino, AppColors.success, false)),
                
                if (!isMobile) ...[
                  const Spacer(),
                  // Detalles extra para escritorio
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.dateTimeFull(tx.fecha).toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted, fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tasa: 1 ${tx.simboloOrigen} = ${tx.tasaCambio.toStringAsFixed(tx.tasaCambio >= 1 ? 4 : 8)}',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.dateTimeFull(tx.fecha).toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted, fontSize: 9),
                  ),
                  Text(
                    'Tasa: ${tx.tasaCambio.toStringAsFixed(tx.tasaCambio >= 1 ? 4 : 8)}',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _cryptoColumnCompact(String symbol, double amount, Color color, bool isOutgoing) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(child: _buildCryptoLogo(symbol)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(symbol, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(
                '${isOutgoing ? "-" : "+"}${amount.toStringAsFixed(amount >= 1 ? 4 : 6)}',
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cryptoColumn(String symbol, double amount, Color color, bool isOutgoing) {
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: _buildCryptoLogo(symbol)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(symbol, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '${isOutgoing ? "-" : "+"}${amount.toStringAsFixed(amount >= 1 ? 4 : 6)}',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoLogo(String symbol) {
    final s = symbol.toLowerCase();
    final extensions = ['.png', '.jpeg', '.jpg', '.webp'];

    Widget image = Image.asset(
      'assets/images/crypto/$s${extensions[0]}',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/crypto/$s${extensions[1]}',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/crypto/$s${extensions[2]}',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/crypto/$s${extensions[3]}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.network(
              'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/$s.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  symbol.substring(0, symbol.length > 2 ? 2 : symbol.length),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (symbol.toUpperCase() == 'BNB' || 
        symbol.toUpperCase() == 'SOL' || 
        symbol.toUpperCase() == 'LTC' || 
        symbol.toUpperCase() == 'PTR' || 
        symbol.toUpperCase() == 'BS') {
      return Transform.scale(scale: 1.5, child: image);
    }

    if (symbol.toUpperCase() == 'ADA' || symbol.toUpperCase() == 'XRP') {
      return Image.network(
        'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/${symbol.toLowerCase()}.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => image,
      );
    }
    return image;
  }

  Widget _infoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted)),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
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


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, color: AppColors.onSurfaceMuted, size: 48),
          const SizedBox(height: 16),
          Text('Sin actividad reciente', style: AppTypography.h4.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Tus intercambios aparecerán aquí', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceMuted)),
        ],
      ),
    ).animate().fadeIn();
  }
}
