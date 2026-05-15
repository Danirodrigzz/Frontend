import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../market/presentation/providers/market_provider.dart';
import '../providers/portfolio_provider.dart';

/// Pantalla del portafolio del usuario.
/// Layout de 3 paneles consistente con el dashboard principal.
class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  /// Colores por activo para el donut chart
  static const Map<String, Color> _assetColors = {
    'BTC': Color(0xFFF7931A),
    'ETH': Color(0xFF627EEA),
    'BNB': Color(0xFFF3BA2F),
    'LTC': Color(0xFFBFBBB6),
    'ADA': Color(0xFF0033AD),
    'XRP': Color(0xFF00AAE4),
    'DOT': Color(0xFFE6007A),
    'SOL': Color(0xFF9945FF),
    'DOGE': Color(0xFFC2A633),
    'LINK': Color(0xFF2A5ADA),
    'USDT': Color(0xFF26A17B),
    'PTR': Color(0xFF1A73E8),
    'BS': Color(0xFFFFB020),
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(portfolioProvider.notifier).cargarSaldos());
  }

  /// Calcula el valor USD de un activo
  double _valorUsd(String simbolo, double saldo, MarketState market) {
    if (simbolo == 'USDT') return saldo;
    if (simbolo == 'PTR') return saldo * 60;
    if (simbolo == 'BS') return saldo / 37.85;
    final data = market.criptos.where((c) => c.shortSymbol == simbolo);
    return data.isNotEmpty ? saldo * data.first.price : 0;
  }

  double _precioUnitario(String simbolo, MarketState market) {
    if (simbolo == 'USDT') return 1;
    if (simbolo == 'PTR') return 60;
    if (simbolo == 'BS') return 1 / 37.85;
    final data = market.criptos.where((c) => c.shortSymbol == simbolo);
    return data.isNotEmpty ? data.first.price : 0;
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final market = ref.watch(marketProvider);

    // Calcular totales
    double valorTotalUsd = 0;
    final activosConValor = <MapEntry<String, double>>[];
    for (final e in portfolio.saldos.entries) {
      if (e.value <= 0) continue;
      final val = _valorUsd(e.key, e.value, market);
      valorTotalUsd += val;
      activosConValor.add(e);
    }

    // Ordenar por valor USD descendente
    activosConValor.sort(
      (a, b) => _valorUsd(
        b.key,
        b.value,
        market,
      ).compareTo(_valorUsd(a.key, a.value, market)),
    );

    // Mejor activo
    final mejorActivo = activosConValor.isNotEmpty
        ? activosConValor.first.key
        : '—';
    final mejorValor = activosConValor.isNotEmpty
        ? _valorUsd(
            activosConValor.first.key,
            activosConValor.first.value,
            market,
          )
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // ═══ COLUMNA IZQUIERDA: Resumen + Distribución ═══════
          SizedBox(
            width: 260,
            child: Column(
              children: [
                // Panel: RESUMEN TOTAL
                Expanded(
                  flex: 5,
                  child: _panel(
                    header: 'RESUMEN DEL PORTAFOLIO',
                    icon: Icons.account_balance_wallet_rounded,
                    child: _buildSummaryContent(
                      valorTotalUsd,
                      activosConValor.length,
                      mejorActivo,
                      mejorValor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Panel: DISTRIBUCIÓN (Donut)
                Expanded(
                  flex: 4,
                  child: _panel(
                    header: 'DISTRIBUCIÓN DE ACTIVOS',
                    icon: Icons.pie_chart_outline_rounded,
                    child: _buildDonutChart(
                      activosConValor,
                      valorTotalUsd,
                      market,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ═══ COLUMNA CENTRAL: Lista de activos ═══════════════
          Expanded(
            child: _panel(
              header: 'MIS ACTIVOS',
              icon: Icons.list_alt_rounded,
              headerExtra: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${activosConValor.length} activos',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              child: _buildAssetList(activosConValor, valorTotalUsd, market),
            ),
          ),

          const SizedBox(width: 10),

          // ═══ COLUMNA DERECHA: Estadísticas rápidas ═══════════
          SizedBox(
            width: 220,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: _panel(
                    header: 'MÉTRICAS RÁPIDAS',
                    icon: Icons.analytics_outlined,
                    child: _buildQuickStats(
                      activosConValor,
                      valorTotalUsd,
                      market,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 4,
                  child: _panel(
                    header: 'CONVERSIONES',
                    icon: Icons.currency_exchange_rounded,
                    child: _buildConversions(valorTotalUsd),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RESUMEN TOTAL
  // ══════════════════════════════════════════════════════════════
  Widget _buildSummaryContent(
    double total,
    int numActivos,
    String mejorActivo,
    double mejorValor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor total estimado',
            style: TextStyle(
              color: AppColors.onSurfaceMuted,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.usd(total),
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),

          // Indicadores en fila
          Row(
            children: [
              _statChip(
                Icons.token_rounded,
                '$numActivos',
                'activos',
                AppColors.primary,
              ),
              const SizedBox(width: 8),
              _statChip(
                Icons.star_rounded,
                mejorActivo,
                'mayor',
                AppColors.warning,
              ),
            ],
          ),

          const Spacer(),

          // Barra de progreso del mayor activo
          Text(
            'Mayor posición',
            style: TextStyle(
              color: AppColors.onSurfaceMuted,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: total > 0 ? (mejorValor / total).clamp(0, 1) : 0,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(
                _assetColors[mejorActivo] ?? AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${total > 0 ? (mejorValor / total * 100).toStringAsFixed(1) : 0}% del portafolio',
            style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DONUT CHART
  // ══════════════════════════════════════════════════════════════
  Widget _buildDonutChart(
    List<MapEntry<String, double>> activos,
    double total,
    MarketState market,
  ) {
    if (activos.isEmpty || total <= 0) {
      return const Center(
        child: Text(
          'Sin activos',
          style: TextStyle(color: AppColors.onSurfaceMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              startDegreeOffset: -90,
              sections: activos.map((e) {
                final val = _valorUsd(e.key, e.value, market);
                final pct = val / total * 100;
                final color = _assetColors[e.key] ?? AppColors.primary;
                return PieChartSectionData(
                  color: color,
                  value: pct,
                  radius: pct > 15 ? 22 : 16,
                  showTitle: pct > 5,
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                );
              }).toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${activos.length}',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'activos',
                style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LISTA DE ACTIVOS
  // ══════════════════════════════════════════════════════════════
  Widget _buildAssetList(
    List<MapEntry<String, double>> activos,
    double total,
    MarketState market,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: activos.length,
      itemBuilder: (_, i) {
        final simbolo = activos[i].key;
        final saldo = activos[i].value;
        final valorUsd = _valorUsd(simbolo, saldo, market);
        final precio = _precioUnitario(simbolo, market);
        final pct = total > 0 ? (valorUsd / total * 100) : 0.0;
        final color = _assetColors[simbolo] ?? AppColors.primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: i == 0
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: i == 0
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Icono circular
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(child: _buildFlexibleLogo(simbolo, color)),
                  ),
                  const SizedBox(width: 12),

                  // Nombre + cantidad
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          simbolo,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${saldo.toStringAsFixed(saldo >= 1 ? 4 : 8)} $simbolo',
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Barra de porcentaje
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Barra mini
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1),
                          child: SizedBox(
                            width: 60,
                            height: 3,
                            child: LinearProgressIndicator(
                              value: (pct / 100).clamp(0, 1).toDouble(),
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Valor USD
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.usd(valorUsd),
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (precio > 0)
                        Text(
                          '@\$${Formatters.cryptoPrice(precio)}',
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted,
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTRICAS RÁPIDAS
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuickStats(
    List<MapEntry<String, double>> activos,
    double total,
    MarketState market,
  ) {
    // Top 3 activos
    final top3 = activos.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 3 posiciones',
            style: TextStyle(
              color: AppColors.onSurfaceMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ...top3.asMap().entries.map((e) {
            final i = e.key;
            final simbolo = e.value.key;
            final valor = _valorUsd(simbolo, e.value.value, market);
            final pct = total > 0 ? (valor / total * 100) : 0.0;
            final color = _assetColors[simbolo] ?? AppColors.primary;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Ranking
                  // Ranking / Logo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildFlexibleLogo(simbolo, color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          simbolo,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // Barra
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0, 1).toDouble(),
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Spacer(),

          // Resumen del rendimiento
          Divider(color: AppColors.border.withValues(alpha: 0.3), height: 16),
          _metricRow('Total activos', '${activos.length}', AppColors.primary),
          _metricRow(
            'Mayor posición',
            top3.isNotEmpty ? top3.first.key : '—',
            AppColors.warning,
          ),
          _metricRow(
            'Valor promedio',
            activos.isNotEmpty ? Formatters.usd(total / activos.length) : '\$0',
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 9),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CONVERSIONES
  // ══════════════════════════════════════════════════════════════
  Widget _buildConversions(double total) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _conversionRow(
            'USD',
            Formatters.usd(total),
            AppColors.primary,
            Icons.attach_money_rounded,
            symbol: 'USDT',
          ),
          _conversionRow(
            'PTR',
            Formatters.usdToPtr(total),
            AppColors.info,
            Icons.account_balance_rounded,
            symbol: 'PTR',
          ),
          _conversionRow(
            'Bs',
            Formatters.usdToBs(total),
            AppColors.warning,
            Icons.monetization_on_outlined,
            symbol: 'BS', 
          ),
          const Spacer(),
          // Nota
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 10,
                  color: AppColors.onSurfaceMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Valores estimados según tasas actuales',
                    style: TextStyle(
                      color: AppColors.onSurfaceMuted,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversionRow(
    String label,
    String value,
    Color color,
    IconData icon, {
    String? symbol,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: symbol != null
                ? ClipOval(child: _buildFlexibleLogo(symbol, color))
                : Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.onSurfaceMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // UTILIDADES (igual que el dashboard)
  // ══════════════════════════════════════════════════════════════
  Widget _panel({
    required String header,
    required IconData icon,
    required Widget child,
    Widget? headerExtra,
  }) {
    return RepaintBoundary(
      child: ClipRRect(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 13),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          header,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      if (headerExtra != null) headerExtra,
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                  style: TextStyle(
                    color: fallbackColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
