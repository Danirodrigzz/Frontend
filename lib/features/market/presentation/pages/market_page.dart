import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/crypto_model.dart';
import '../../data/repositories/market_repository.dart';
import '../providers/market_provider.dart';

/// Dashboard principal con layout de 3 columnas:
///  - Columna izquierda: MULTI-ASSET PORTFOLIO (donut) + TRENDING SIGNALS
///  - Columna central: Gráfica principal grande + COMMUNITY INSIGHTS abajo
///  - Columna derecha: FAST TRADE & INFO + SENTIMENT & NEWS
class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  final MarketRepository _marketRepo = MarketRepository();
  int _selectedCryptoIndex = 0;
  List<KlineModel> _chartData = [];
  bool _loadingChart = true;
  String _chartInterval = '1h';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(marketProvider.notifier).cargarCriptos());
  }

  Future<void> _loadChart(String symbol) async {
    setState(() => _loadingChart = true);
    try {
      final klines = await _marketRepo.obtenerKlines(
        symbol: symbol, interval: _chartInterval, limit: 48,
      );
      if (mounted) setState(() { _chartData = klines; _loadingChart = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingChart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketProvider);

    if (state.criptos.isNotEmpty && _chartData.isEmpty) {
      _loadChart(state.criptos.first.symbol);
    }
    if (state.estaCargando && state.criptos.isEmpty) return _buildLoading();
    if (state.error != null && state.criptos.isEmpty) return _buildError(state.error!);

    final selected = state.criptos.isNotEmpty && _selectedCryptoIndex < state.criptos.length
        ? state.criptos[_selectedCryptoIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Orbes de Luz de Fondo (Para lucir el Glassmorphism) ───
          _buildBackgroundOrbs(),

          // ── Contenido Principal ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // ═══ COLUMNA IZQUIERDA ═══════════════════════════════
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      // Panel: MULTI-ASSET PORTFOLIO (donut + lista)
                      Expanded(flex: 5, child: _buildPortfolioPanel(state)),
                      const SizedBox(height: 10),
                      // Panel: TRENDING SIGNALS
                      Expanded(flex: 4, child: _buildTrendingPanel(state)),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                 .blur(begin: const Offset(10, 10), end: Offset.zero, duration: 1000.ms)
                 .shimmer(delay: 400.ms, duration: 1200.ms, color: Colors.white.withValues(alpha: 0.1)),
                
                const SizedBox(width: 10),

                // ═══ COLUMNA CENTRAL ═════════════════════════════════
                Expanded(
                  child: RepaintBoundary(
                    child: Column(
                      children: [
                        // Panel: GRÁFICA PRINCIPAL (grande)
                        Expanded(flex: 6, child: _buildMainChartPanel(selected)),
                        const SizedBox(height: 10),
                        // Panel: COMMUNITY INSIGHTS
                        Expanded(flex: 2, child: _buildCommunityPanel(state)),
                      ],
                    ),
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms, delay: 200.ms)
                 .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 1200.ms)
                 .shimmer(delay: 600.ms, duration: 1500.ms, color: AppColors.primary.withValues(alpha: 0.2)),
                
                const SizedBox(width: 10),

                // ═══ COLUMNA DERECHA ═════════════════════════════════
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      // Panel: FAST TRADE & INFO
                      Expanded(flex: 5, child: _buildTradingPanel(selected)),
                      const SizedBox(height: 10),
                      // Panel: SENTIMENT & NEWS
                      Expanded(flex: 4, child: _buildSentimentPanel(state)),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms, delay: 400.ms)
                 .blur(begin: const Offset(10, 10), end: Offset.zero, duration: 1000.ms)
                 .shimmer(delay: 800.ms, duration: 1200.ms, color: Colors.white.withValues(alpha: 0.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COLUMNA IZQUIERDA — MULTI-ASSET PORTFOLIO
  // ══════════════════════════════════════════════════════════════

  /// Mapa de colores e iconos oficiales por símbolo de cripto
  static const Map<String, _CryptoIcon> _cryptoIcons = {
    'BTC': _CryptoIcon('₿', Color(0xFFF7931A)),
    'ETH': _CryptoIcon('Ξ', Color(0xFF627EEA)),
    'BNB': _CryptoIcon('B', Color(0xFFF3BA2F)),
    'LTC': _CryptoIcon('Ł', Color(0xFFBFBBB6)),
    'ADA': _CryptoIcon('₳', Color(0xFF0033AD)),
    'XRP': _CryptoIcon('✕', Color(0xFF00AAE4)),
    'DOT': _CryptoIcon('●', Color(0xFFE6007A)),
    'SOL': _CryptoIcon('◎', Color(0xFF9945FF)),
    'DOGE': _CryptoIcon('Ð', Color(0xFFC2A633)),
    'LINK': _CryptoIcon('⬡', Color(0xFF2A5ADA)),
  };

  Widget _buildPortfolioPanel(MarketState state) {
    return _panel(
      header: 'PORTAFOLIO MULTI-ACTIVOS',
      icon: Icons.pie_chart_outline_rounded,
      child: Column(
        children: [
          // Donut Chart mejorado
          Expanded(
            flex: 4,
            child: state.criptos.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 32,
                          startDegreeOffset: -90,
                          sections: List.generate(
                            min(state.criptos.length, 7),
                            (i) {
                              final total = state.criptos.fold<double>(
                                  0, (s, c) => s + c.quoteVolume);
                              final pct = total > 0
                                  ? (state.criptos[i].quoteVolume / total * 100)
                                  : 0.0;
                              final icon = _cryptoIcons[state.criptos[i].shortSymbol];
                              return PieChartSectionData(
                                color: icon?.color ?? AppColors.primary,
                                value: pct,
                                radius: pct > 20 ? 22 : 18,
                                showTitle: pct > 5,
                                title: '${pct.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                                ),
                              );
                            },
                          ),
                        )),
                        // Centro del donut
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${state.criptos.length}',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'activos',
                              style: TextStyle(
                                color: AppColors.onSurfaceMuted,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          // Divider sutil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(color: AppColors.border.withValues(alpha: 0.3), height: 1),
          ),

          // Lista de criptos con iconos de marca
          Expanded(
            flex: 5,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              itemCount: state.criptos.length,
              itemBuilder: (_, i) {
                final crypto = state.criptos[i];
                final isSelected = i == _selectedCryptoIndex;
                final icon = _cryptoIcons[crypto.shortSymbol];
                final brandColor = icon?.color ?? AppColors.primary;
                final esPositivo = crypto.priceChangePercent >= 0;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedCryptoIndex = i);
                    _loadChart(crypto.symbol);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.15))
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Icono de la cripto (Logo limpio)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: _buildCryptoLogo(crypto.shortSymbol, brandColor),
                        ),
                        const SizedBox(width: 12),
                        // Nombre y símbolo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crypto.shortSymbol,
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '\$${Formatters.cryptoPrice(crypto.price)}',
                                style: TextStyle(
                                  color: AppColors.onSurfaceMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cambio %
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: (esPositivo ? AppColors.success : AppColors.error)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '${esPositivo ? '+' : ''}${crypto.priceChangePercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: esPositivo ? AppColors.success : AppColors.error,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COLUMNA IZQUIERDA — TRENDING SIGNALS
  // ══════════════════════════════════════════════════════════════
  Widget _buildTrendingPanel(MarketState state) {
    final trending = List<CryptoModel>.from(state.criptos)
      ..sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));

    return _panel(
      header: 'TENDENCIAS Y ESTIMACIONES',
      icon: Icons.trending_up_rounded,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: min(trending.length, 4),
        itemBuilder: (_, i) {
          final crypto = trending[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => context.go('/crypto/${crypto.symbol}'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_graph_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(crypto.name, style: TextStyle(
                          color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${crypto.shortSymbol} • \$${Formatters.cryptoPrice(crypto.price)} • ${Formatters.percentage(crypto.priceChangePercent)}',
                      style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COLUMNA CENTRAL — GRÁFICA PRINCIPAL
  // ══════════════════════════════════════════════════════════════
  Widget _buildMainChartPanel(CryptoModel? crypto) {
    return _panel(
      header: crypto != null
          ? '${crypto.name} (${crypto.shortSymbol}/USDT)'
          : 'NEXUS GLOBAL DE CRIPTO',
      icon: Icons.show_chart_rounded,
      headerExtra: Row(
        children: [
          _intervalChip('1h', '1h'),
          _intervalChip('4h', '4h'),
          _intervalChip('1d', '1d'),
          _intervalChip('1w', '1s'),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtítulo
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              'VOLUMEN DE TOKENS EN TIEMPO REAL',
              style: TextStyle(
                color: AppColors.onSurfaceMuted, fontSize: 9, letterSpacing: 1,
              ),
            ),
          ),
          // Precio grande
          if (crypto != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${Formatters.cryptoPrice(crypto.price)}',
                    style: AppTypography.priceLarge.copyWith(
                      color: AppColors.onSurface, fontSize: 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _changeBadge(crypto.priceChangePercent, fontSize: 12),
                ],
              ),
            ),
          // Gráfica
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: _loadingChart
                  ? Center(child: SpinKitPulsingGrid(color: AppColors.primary, size: 32))
                  : _chartData.isEmpty
                      ? Center(child: Text('Sin datos', style: TextStyle(color: AppColors.onSurfaceMuted)))
                      : _buildMainChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _intervalChip(String value, String label) {
    final active = value == _chartInterval;
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: InkWell(
        onTap: () {
          setState(() => _chartInterval = value);
          final state = ref.read(marketProvider);
          if (state.criptos.isNotEmpty) _loadChart(state.criptos[_selectedCryptoIndex].symbol);
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
          child: Text(label, style: TextStyle(
            color: active ? AppColors.primary : AppColors.onSurfaceMuted,
            fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          )),
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    final spots = _chartData.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.close)).toList();
    final prices = _chartData.map((k) => k.close).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);
    final margin = (maxY - minY) * 0.2;

    return Stack(
      children: [
        // ── Capa de Fondo: Barras de Volumen (Simuladas) ──────────
        Positioned.fill(
          bottom: 0,
          top: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(20, (i) => Container(
              width: 4,
              height: (20 + (i % 7) * 10).toDouble(),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(1),
              ),
            )),
          ),
        ),

        // ── Capa Principal: Gráfica de Línea ──────────────────────
        LineChart(LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.white.withValues(alpha: 0.03),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, 
              reservedSize: 55, // Aumentado para evitar saltos de línea
              getTitlesWidget: (v, m) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  Formatters.cryptoPrice(v), 
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.onSurfaceMuted, 
                    fontSize: 8,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            )),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: minY - margin, maxY: maxY + margin,
          
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2, // Más técnica, menos curva
              barWidth: 2,
              // Gradiente en la propia línea
              gradient: const LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFFA855F7)],
              ),
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF007AFF).withValues(alpha: 0.2),
                    const Color(0xFFA855F7).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1A1A2E),
              tooltipBorder: const BorderSide(color: Color(0xFF007AFF)),
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem(
                '\$${Formatters.cryptoPrice(s.y)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              )).toList(),
            ),
          ),
        )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COLUMNA CENTRAL ABAJO — COMMUNITY INSIGHTS
  // ══════════════════════════════════════════════════════════════
  Widget _buildCommunityPanel(MarketState state) {
    // Usamos URLs directas para asegurar visualización inmediata en Web mientras se asientan los local assets
    final List<Map<String, dynamic>> communityCryptos = [
      {'symbol': 'XRP', 'color': const Color(0xFF23292F), 'change': -4.06, 'logo': 'https://cryptologos.cc/logos/xrp-xrp-logo.png'},
      {'symbol': 'UNI', 'color': const Color(0xFFFF007A), 'change': 3.04, 'logo': 'https://cryptologos.cc/logos/uniswap-uni-logo.png'},
      {'symbol': 'LINK', 'color': const Color(0xFF2A5ADA), 'change': 2.74, 'logo': 'https://cryptologos.cc/logos/chainlink-link-logo.png'},
      {'symbol': 'DOT', 'color': const Color(0xFFE6007A), 'change': 2.71, 'logo': 'https://cryptologos.cc/logos/polkadot-new-dot-logo.png'},
    ];

    return _panel(
      header: 'PERSPECTIVAS DE LA COMUNIDAD',
      icon: Icons.bubble_chart_rounded,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: communityCryptos.map((crypto) {
              final positive = crypto['change'] >= 0;
              final String localAsset = 'assets/images/crypto/${crypto['symbol'].toLowerCase()}.png';
              final String fallbackUrl = 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/${crypto['symbol'].toLowerCase()}.png';

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Circular limpio
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: _buildCryptoLogo(crypto['symbol'], crypto['color']),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    crypto['symbol'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Porcentaje con flecha
                  Row(
                    children: [
                      Icon(
                        positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 8,
                        color: positive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        '${positive ? '+' : ''}${crypto['change']}%',
                        style: TextStyle(
                          color: positive ? AppColors.success : AppColors.error,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COLUMNA DERECHA — FAST TRADE & INFO
  // ══════════════════════════════════════════════════════════════
  Widget _buildTradingPanel(CryptoModel? crypto) {
    return _panel(
      header: 'OPERACIÓN RÁPIDA E INFO',
      icon: Icons.bolt_rounded,
      child: crypto == null
          ? const SizedBox()
          : Column(
              children: [
                _infoRow('Precio', '\$${Formatters.cryptoPrice(crypto.price)}', AppColors.onSurface),
                _infoRow('Máx 24h', '\$${Formatters.cryptoPrice(crypto.high24h)}', AppColors.success),
                _infoRow('Mín 24h', '\$${Formatters.cryptoPrice(crypto.low24h)}', AppColors.error),
                _infoRow('Volumen', '\$${Formatters.volume(crypto.quoteVolume)}', AppColors.info),
                _infoRow('Cambio', Formatters.percentage(crypto.priceChangePercent),
                    crypto.priceChangePercent >= 0 ? AppColors.success : AppColors.error),
                Divider(color: AppColors.border.withValues(alpha: 0.3), height: 16),
                _infoRow('Precio PTR', Formatters.usdToPtr(crypto.price), AppColors.warning),
                _infoRow('Precio Bs', Formatters.usdToBs(crypto.price), AppColors.primaryLight),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/exchange'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('INTERCAMBIAR', style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1,
                      )),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 10)),
          Text(value, style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace',
          )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COLUMNA DERECHA ABAJO — SENTIMENT & NEWS
  // ══════════════════════════════════════════════════════════════
  Widget _buildSentimentPanel(MarketState state) {
    return _panel(
      header: 'SENTIMIENTO Y NOTICIAS',
      icon: Icons.analytics_outlined,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de Sentimiento
            Text('Sentimiento de la Comunidad', style: TextStyle(
              color: AppColors.onSurface, fontSize: 10, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Bajista', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 8)),
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [AppColors.error, AppColors.warning, AppColors.success],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0.7 * 160, // Dummy pos
                          child: Container(
                            width: 2, height: 4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text('Alcista', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 8)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sección de Noticias
            Row(
              children: [
                Icon(Icons.newspaper_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Últimas Noticias', style: TextStyle(
                  color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Titular: "Bitcoin alcanza nuevos máximos"', style: TextStyle(
                    color: AppColors.onSurface, fontSize: 10, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 4),
                  Text('El mercado muestra una fuerte tendencia alcista tras los últimos informes institucionales...', 
                    style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 9),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ══════════════════════════════════════════════════════════════
  Widget _changeBadge(double percent, {double fontSize = 10}) {
    final positive = percent >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: (positive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '${positive ? '+' : ''}${percent.toStringAsFixed(1)}%',
        style: TextStyle(
          color: positive ? AppColors.success : AppColors.error,
          fontSize: fontSize, fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _panel({required String header, required IconData icon, required Widget child, Widget? headerExtra}) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7), // Optimizado para fluidez
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 13),
                      const SizedBox(width: 8),
                      Expanded(child: Text(header, style: TextStyle(
                        color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6,
                      ))),
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

  Widget _buildLoading() => Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(
      children: [
        // ── Consistencia visual con orbes ──
        _buildBackgroundOrbs(),
        
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con Fallback y animación de pulsación
              SvgPicture.asset(
                'assets/images/logo-2.svg',
                height: 120,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                // Fallback si el SVG falla en la web
                placeholderBuilder: (context) => Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  color: Colors.white,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOut),
              
              const SizedBox(height: 40),
              
              // Spinner elegante
              SpinKitPulsingGrid(color: AppColors.primary, size: 40),
              
              const SizedBox(height: 20),
              
              Text('SINCRONIZANDO MERCADO', style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.7), 
                fontSize: 10, 
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              )).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildError(String error) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
      const SizedBox(height: 16),
      Text('Error al cargar', style: AppTypography.h3.copyWith(color: AppColors.onSurface)),
      const SizedBox(height: 8),
      Text(error, style: TextStyle(color: AppColors.onSurfaceMuted)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () => ref.read(marketProvider.notifier).cargarCriptos(),
        icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar'),
      ),
    ],
  ));
  /// Helper para construir el logo con múltiples fallbacks de extensión
  Widget _buildCryptoLogo(String symbol, Color color) {
    final s = symbol.toLowerCase();
    // Lista de extensiones a probar localmente (según lo visto en la carpeta)
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
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// Crea orbes de color difuminados en el fondo para que el blur de las tarjetas sea visible.
  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -100, left: -50,
          child: _orb(250, AppColors.primary.withValues(alpha: 0.12)),
        ),
        Positioned(
          bottom: 100, right: -100,
          child: _orb(300, const Color(0xFF6366F1).withValues(alpha: 0.1)),
        ),
        Positioned(
          top: 200, right: 100,
          child: _orb(150, const Color(0xFFA855F7).withValues(alpha: 0.08)),
        ),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Clase auxiliar para definir el icono y color de marca de cada cripto.
class _CryptoIcon {
  final String symbol;
  final Color color;
  const _CryptoIcon(this.symbol, this.color);
}
