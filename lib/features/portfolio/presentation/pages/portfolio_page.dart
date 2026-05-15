import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../market/presentation/providers/market_provider.dart';
import '../providers/portfolio_provider.dart';

/// Pantalla del portafolio del usuario.
/// Muestra el valor total y un listado detallado de todos los saldos
/// con su equivalencia en USD según los precios del mercado.
class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(portfolioProvider.notifier).cargarSaldos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final market = ref.watch(marketProvider);

    // Calcular el valor total del portafolio en USD
    double valorTotalUsd = 0;
    for (final entry in portfolio.saldos.entries) {
      if (entry.key == 'USDT') {
        valorTotalUsd += entry.value;
      } else if (entry.key == 'PTR') {
        valorTotalUsd += entry.value * 60;
      } else if (entry.key == 'BS') {
        valorTotalUsd += entry.value / 37.85;
      } else {
        final cryptoData = market.criptos.where(
          (c) => c.shortSymbol == entry.key,
        );
        if (cryptoData.isNotEmpty) {
          valorTotalUsd += entry.value * cryptoData.first.price;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ───────────────────────────────────
          Text(
            'Mi Portafolio',
            style: AppTypography.h2.copyWith(color: AppColors.onSurface),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 20),

          // ── Tarjeta de valor total ───────────────────────
          GlassmorphicCard(
            highlight: true,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor total estimado',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.usd(valorTotalUsd),
                  style: AppTypography.priceLarge.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      Formatters.usdToPtr(valorTotalUsd),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      Formatters.usdToBs(valorTotalUsd),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 150.ms),

          const SizedBox(height: 24),

          // ── Listado de activos ───────────────────────────
          Text(
            'Mis activos',
            style: AppTypography.h4.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),

          ...portfolio.saldos.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final simbolo = entry.value.key;
            final saldo = entry.value.value;

            // Calcular valor en USD
            double valorUsd = 0;
            double precioUnitario = 0;
            if (simbolo == 'USDT') {
              valorUsd = saldo;
              precioUnitario = 1;
            } else if (simbolo == 'PTR') {
              valorUsd = saldo * 60;
              precioUnitario = 60;
            } else if (simbolo == 'BS') {
              valorUsd = saldo / 37.85;
              precioUnitario = 1 / 37.85;
            } else {
              final cryptoData = market.criptos.where(
                (c) => c.shortSymbol == simbolo,
              );
              if (cryptoData.isNotEmpty) {
                precioUnitario = cryptoData.first.price;
                valorUsd = saldo * precioUnitario;
              }
            }

            if (saldo <= 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassmorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Ícono del activo limpio
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _buildFlexibleLogo(simbolo, AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nombre y cantidad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            simbolo,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${saldo.toStringAsFixed(saldo >= 1 ? 4 : 8)} $simbolo',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Valor en USD
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.usd(valorUsd),
                          style: AppTypography.priceSmall.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (precioUnitario > 0)
                          Text(
                            '@\$${Formatters.cryptoPrice(precioUnitario)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (200 + index * 60).ms, duration: 400.ms)
                .slideX(begin: 0.05, end: 0, delay: (200 + index * 60).ms);
          }),
        ],
      ),
    );
  }

  // Helper para cargar logos con múltiples extensiones
  Widget _buildFlexibleLogo(String symbol, Color fallbackColor) {
    final s = symbol.toLowerCase();
    final extensions = ['.png', '.jpeg', '.jpg', '.webp'];

    return Image.asset(
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
                  style: AppTypography.labelMedium.copyWith(
                    color: fallbackColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
