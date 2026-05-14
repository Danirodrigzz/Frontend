import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../providers/history_provider.dart';

/// Pantalla del historial de transacciones realizadas.
/// Muestra la lista cronológica de todos los intercambios
/// con detalles de fecha, criptos, cantidades y tasa de cambio.
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ───────────────────────────────────
          Text(
            'Historial de Transacciones',
            style: AppTypography.h2.copyWith(color: AppColors.onSurface),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            '${historyState.transacciones.length} transacciones registradas',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // ── Lista de transacciones ───────────────────────
          Expanded(
            child: historyState.transacciones.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: historyState.transacciones.length,
                    itemBuilder: (context, index) {
                      final tx = historyState.transacciones[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassmorphicCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fecha y hora
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    color: AppColors.onSurfaceMuted,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    Formatters.dateTimeFull(tx.fecha),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceMuted,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Intercambio',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Detalle del intercambio
                              Row(
                                children: [
                                  // Cripto origen
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enviado',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.error.withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '-${tx.cantidadOrigen.toStringAsFixed(
                                            tx.cantidadOrigen >= 1 ? 4 : 8,
                                          )} ${tx.simboloOrigen}',
                                          style: AppTypography.priceSmall.copyWith(
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Flecha de dirección
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),

                                  // Cripto destino
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Recibido',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.success.withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '+${tx.cantidadDestino.toStringAsFixed(
                                            tx.cantidadDestino >= 1 ? 4 : 8,
                                          )} ${tx.simboloDestino}',
                                          style: AppTypography.priceSmall.copyWith(
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              Divider(
                                color: AppColors.divider.withValues(alpha: 0.3),
                                height: 1,
                              ),
                              const SizedBox(height: 8),

                              // Tasa de cambio
                              Text(
                                'Tasa: 1 ${tx.simboloOrigen} = ${tx.tasaCambio.toStringAsFixed(
                                  tx.tasaCambio >= 1 ? 4 : 8,
                                )} ${tx.simboloDestino}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (100 + index * 60).ms, duration: 400.ms)
                          .slideY(begin: 0.05, end: 0, delay: (100 + index * 60).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Estado vacío cuando no hay transacciones
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: AppColors.onSurfaceMuted,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin transacciones',
            style: AppTypography.h3.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Realiza tu primer intercambio para ver el historial aquí',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 500.ms)
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            delay: 200.ms,
          ),
    );
  }
}
