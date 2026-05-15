import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../data/models/crypto_model.dart';
import '../../data/repositories/market_repository.dart';
import '../providers/market_provider.dart';

/// Pantalla de detalle de una criptomoneda específica.
/// Muestra gráfico interactivo de precios, estadísticas 24h,
/// conversiones a PTR/BS y botón de intercambio directo.
class CryptoDetailPage extends ConsumerStatefulWidget {
  final String symbol;

  const CryptoDetailPage({super.key, required this.symbol});

  @override
  ConsumerState<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends ConsumerState<CryptoDetailPage> {
  String _intervaloSeleccionado = '1h';
  List<KlineModel> _klines = [];
  bool _cargandoChart = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosGrafico();
  }

  /// Carga los datos de velas para el gráfico de precios
  Future<void> _cargarDatosGrafico() async {
    setState(() => _cargandoChart = true);
    try {
      final repo = MarketRepository();
      final klines = await repo.obtenerKlines(
        symbol: widget.symbol,
        interval: _intervaloSeleccionado,
        limit: 48,
      );
      if (mounted) {
        setState(() {
          _klines = klines;
          _cargandoChart = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoChart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(marketProvider);

    // Buscar la cripto en los datos del mercado
    final crypto = marketState.criptos.where(
      (c) => c.symbol == widget.symbol,
    );

    if (crypto.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = crypto.first;
    final esPositivo = data.priceChangePercent >= 0;
    final colorCambio = esPositivo ? AppColors.success : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navegación para volver atrás
          _buildBreadcrumb(data),
          const SizedBox(height: 20),

          // Información principal del precio
          _buildPriceHeader(data, colorCambio, esPositivo),
          const SizedBox(height: 24),

          // Gráfico de precios
          _buildChartSection(data),
          const SizedBox(height: 24),

          // Estadísticas y conversiones
          _buildStatsGrid(data),
          const SizedBox(height: 24),

          // Botón de intercambio
          _buildExchangeButton(data),
        ],
      ),
    );
  }

  /// Breadcrumb de navegación con botón de retorno
  Widget _buildBreadcrumb(CryptoModel crypto) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/'),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Mercado',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.onSurfaceMuted,
          size: 18,
        ),
        Text(
          '${crypto.name} (${crypto.shortSymbol})',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Encabezado con precio actual y cambio porcentual
  Widget _buildPriceHeader(CryptoModel crypto, Color colorCambio, bool esPositivo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Ícono de la cripto
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              crypto.shortSymbol.substring(0, 2),
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crypto.name,
              style: AppTypography.h3.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${Formatters.cryptoPrice(crypto.price)}',
                  style: AppTypography.priceLarge.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorCambio.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        esPositivo ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: colorCambio,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.percentage(crypto.priceChangePercent),
                        style: AppTypography.percentage.copyWith(color: colorCambio),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideX(begin: -0.05, end: 0, delay: 100.ms);
  }

  /// Sección del gráfico de precios con selectores de intervalo
  Widget _buildChartSection(CryptoModel crypto) {
    final intervalos = ['1h', '4h', '1d', '1w'];

    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gráfico de precios',
                style: AppTypography.h4.copyWith(color: AppColors.onSurface),
              ),
              const Spacer(),
              // Selectores de intervalo
              ...intervalos.map((intervalo) {
                final estaActivo = intervalo == _intervaloSeleccionado;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() => _intervaloSeleccionado = intervalo);
                      _cargarDatosGrafico();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: estaActivo
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: estaActivo
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        intervalo.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: estaActivo ? AppColors.primary : AppColors.onSurfaceVariant,
                          fontWeight: estaActivo ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfico
          SizedBox(
            height: 280,
            child: _cargandoChart
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  )
                : _klines.isEmpty
                    ? Center(
                        child: Text(
                          'Sin datos disponibles',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : _buildPriceChart(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.05, end: 0, delay: 200.ms);
  }

  /// Gráfico de líneas con área rellena y gradiente
  Widget _buildPriceChart() {
    final spots = _klines.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();

    final minY = _klines.map((k) => k.close).reduce((a, b) => a < b ? a : b);
    final maxY = _klines.map((k) => k.close).reduce((a, b) => a > b ? a : b);
    final margen = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border.withValues(alpha: 0.3),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${Formatters.cryptoPrice(value)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceMuted,
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY - margen,
        maxY: maxY + margen,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.surfaceElevated,
            tooltipBorder: BorderSide(color: AppColors.border),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${Formatters.cryptoPrice(spot.y)}',
                  AppTypography.priceSmall.copyWith(color: AppColors.primary),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// Grid de estadísticas y conversiones a PTR/BS
  Widget _buildStatsGrid(CryptoModel crypto) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard(
          'Máximo 24h',
          '\$${Formatters.cryptoPrice(crypto.high24h)}',
          Icons.arrow_upward_rounded,
          AppColors.success,
          0,
        ),
        _buildStatCard(
          'Mínimo 24h',
          '\$${Formatters.cryptoPrice(crypto.low24h)}',
          Icons.arrow_downward_rounded,
          AppColors.error,
          1,
        ),
        _buildStatCard(
          'Volumen 24h',
          '\$${Formatters.volume(crypto.quoteVolume)}',
          Icons.bar_chart_rounded,
          AppColors.info,
          2,
        ),
        _buildStatCard(
          'Precio en PTR',
          Formatters.usdToPtr(crypto.price),
          Icons.monetization_on_rounded,
          AppColors.warning,
          3,
        ),
        _buildStatCard(
          'Precio en Bs',
          Formatters.usdToBs(crypto.price),
          Icons.attach_money_rounded,
          AppColors.primaryLight,
          4,
        ),
        _buildStatCard(
          'Capitalización',
          '${AppConstants.cryptoSymbols[crypto.symbol] ?? ''}/USDT',
          Icons.public_rounded,
          AppColors.onSurfaceVariant,
          5,
        ),
      ],
    );
  }

  /// Card individual de estadística con animación
  Widget _buildStatCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
    int index,
  ) {
    return SizedBox(
      width: 200,
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: AppTypography.priceMedium.copyWith(
                color: AppColors.onSurface,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (300 + index * 80).ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: (300 + index * 80).ms,
        );
  }

  /// Botón grande de intercambio directo
  Widget _buildExchangeButton(CryptoModel crypto) {
    return Center(
      child: SizedBox(
        width: 320,
        child: ElevatedButton.icon(
          onPressed: () => context.go('/exchange'),
          icon: const Icon(Icons.swap_horiz_rounded, size: 22),
          label: Text(
            'Intercambiar ${crypto.shortSymbol}',
            style: AppTypography.button,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 600.ms);
  }
}
