import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/crypto_model.dart';
import '../providers/market_provider.dart';

/// Pantalla principal del mercado de criptomonedas.
/// Tabla con precios en tiempo real, búsqueda, ordenamiento,
/// staggered animations y loaders con spinkit.
class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(marketProvider.notifier).cargarCriptos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(marketProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(marketState),
          const SizedBox(height: 20),
          _buildSearchAndFilters(marketState),
          const SizedBox(height: 16),
          Expanded(
            child: marketState.estaCargando && marketState.criptos.isEmpty
                ? _buildLoadingState()
                : marketState.error != null && marketState.criptos.isEmpty
                    ? _buildErrorState(marketState.error!)
                    : _buildCryptoTable(marketState),
          ),
        ],
      ),
    );
  }

  /// Encabezado con título y countdown
  Widget _buildSectionHeader(MarketState state) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mercado',
                  style: AppTypography.h2.copyWith(color: AppColors.onSurface),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '${state.criptos.length} criptomonedas · Datos en tiempo real',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (state.criptos.isNotEmpty)
          _buildRefreshIndicator(state.segundosParaRefresh),
      ],
    );
  }

  /// Indicador circular de auto-refresh con glow
  Widget _buildRefreshIndicator(int segundos) {
    final progreso = segundos / 30;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progreso,
                  strokeWidth: 2,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.accent.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '$segundos',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Auto',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms);
  }

  /// Barra de búsqueda y dropdown de orden
  Widget _buildSearchAndFilters(MarketState state) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref.read(marketProvider.notifier).buscar(v),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar criptomoneda...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<OrdenCripto>(
              value: state.orden,
              dropdownColor: AppColors.surfaceElevated,
              icon: const Icon(Icons.unfold_more_rounded,
                  color: AppColors.onSurfaceVariant, size: 18),
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurface),
              items: const [
                DropdownMenuItem(value: OrdenCripto.volumenDesc, child: Text('Mayor volumen')),
                DropdownMenuItem(value: OrdenCripto.precioDesc, child: Text('Mayor precio')),
                DropdownMenuItem(value: OrdenCripto.precioAsc, child: Text('Menor precio')),
                DropdownMenuItem(value: OrdenCripto.cambioDesc, child: Text('Mayor cambio %')),
                DropdownMenuItem(value: OrdenCripto.cambioAsc, child: Text('Menor cambio %')),
                DropdownMenuItem(value: OrdenCripto.nombreAsc, child: Text('Nombre A-Z')),
              ],
              onChanged: (v) {
                if (v != null) ref.read(marketProvider.notifier).ordenar(v);
              },
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 200.ms);
  }

  /// Tabla de criptomonedas con staggered animations
  Widget _buildCryptoTable(MarketState state) {
    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: 4),
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              itemCount: state.criptosFiltradas.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 450),
                  child: SlideAnimation(
                    horizontalOffset: 40.0,
                    child: FadeInAnimation(
                      child: _buildCryptoRow(state.criptosFiltradas[index], index),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Encabezado de la tabla
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          _headerCell('Nombre', 3),
          _headerCell('Precio', 2, align: TextAlign.right),
          _headerCell('Cambio 24h', 2, align: TextAlign.right),
          _headerCell('Volumen', 2, align: TextAlign.right),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex, {TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
        textAlign: align,
      ),
    );
  }

  /// Fila de una criptomoneda
  Widget _buildCryptoRow(CryptoModel crypto, int index) {
    final esPositivo = crypto.priceChangePercent >= 0;
    final colorCambio = esPositivo ? AppColors.success : AppColors.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/crypto/${crypto.symbol}'),
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              // Ícono con gradiente
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    crypto.shortSymbol.substring(
                      0, crypto.shortSymbol.length > 2 ? 2 : crypto.shortSymbol.length,
                    ),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crypto.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      crypto.shortSymbol,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  '\$${Formatters.cryptoPrice(crypto.price)}',
                  style: AppTypography.priceSmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorCambio.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colorCambio.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            esPositivo
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: colorCambio,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.percentage(crypto.priceChangePercent),
                            style: AppTypography.percentage.copyWith(
                              color: colorCambio,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  '\$${Formatters.volume(crypto.quoteVolume)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado de carga con SpinKit spinner
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitPulsingGrid(
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando datos del mercado...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        ],
      ),
    );
  }

  /// Estado de error con reintentar
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error.withValues(alpha: 0.6),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: AppTypography.h3.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(marketProvider.notifier).cargarCriptos(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }
}
