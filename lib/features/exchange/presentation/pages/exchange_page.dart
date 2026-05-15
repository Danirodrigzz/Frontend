import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/animated_orbs_background.dart';
import '../../../market/presentation/providers/market_provider.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../market/data/models/crypto_model.dart';

/// Pantalla de intercambio de criptomonedas.
/// Permite seleccionar cripto origen y destino, ingresar cantidad
/// y ejecutar el intercambio con cálculo automático de la tasa.
class ExchangePage extends ConsumerStatefulWidget {
  const ExchangePage({super.key});

  @override
  ConsumerState<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends ConsumerState<ExchangePage>
    with SingleTickerProviderStateMixin {
  String _simboloOrigen = 'BTC';
  String _simboloDestino = 'USDT';
  final _cantidadController = TextEditingController();
  double _cantidadDestino = 0;
  String? _errorMessage;
  double _tasaCambio = 0;
  int _countdown = AppConstants.exchangeRateExpirySeconds;
  Timer? _timerTasa;
  bool _procesando = false;
  bool _intercambioExitoso = false;

  // Controlador para la animación del botón swap
  late AnimationController _swapController;

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iniciarTimerTasa();
    _cantidadController.addListener(_calcularConversion);
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _timerTasa?.cancel();
    _swapController.dispose();
    super.dispose();
  }

  /// Inicia el countdown de la tasa de cambio
  void _iniciarTimerTasa() {
    _timerTasa?.cancel();
    _countdown = AppConstants.exchangeRateExpirySeconds;
    _timerTasa = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _countdown = AppConstants.exchangeRateExpirySeconds;
            _calcularConversion(); // Recalcular tasa
          }
        });
      }
    });
  }

  /// Calcula la conversión basada en los precios del mercado
  void _calcularConversion() {
    setState(() => _errorMessage = null);
    final market = ref.read(marketProvider);
    final cantidadTexto = _cantidadController.text;
    final cantidad = double.tryParse(cantidadTexto.replaceAll(',', '.')) ?? 0;

    // Obtener precio del origen en USD
    double precioOrigenUsd = _obtenerPrecioUsd(_simboloOrigen, market);
    double precioDestinoUsd = _obtenerPrecioUsd(_simboloDestino, market);

    if (precioDestinoUsd > 0) {
      _tasaCambio = precioOrigenUsd / precioDestinoUsd;
      _cantidadDestino = cantidad * _tasaCambio;
    } else {
      _tasaCambio = 0;
      _cantidadDestino = 0;
    }

    setState(() {});
  }

  /// Obtiene el precio en USD de un símbolo dado
  double _obtenerPrecioUsd(String simbolo, MarketState market) {
    if (simbolo == 'USDT') return 1.0;
    if (simbolo == 'PTR') return AppConstants.ptrToUsd;
    if (simbolo == 'BS') return 1.0 / AppConstants.bsPerUsd;

    final crypto = market.criptos.where((c) => c.shortSymbol == simbolo);
    return crypto.isNotEmpty ? crypto.first.price : 0;
  }

  /// Intercambia las criptos de origen y destino
  void _intercambiarDireccion() {
    _swapController.forward(from: 0);
    setState(() {
      final temp = _simboloOrigen;
      _simboloOrigen = _simboloDestino;
      _simboloDestino = temp;
      _calcularConversion();
    });
  }

  /// Ejecuta el intercambio de criptomonedas
  Future<void> _ejecutarIntercambio() async {
    final cantidad =
        double.tryParse(_cantidadController.text.replaceAll(',', '.')) ?? 0;

    if (cantidad <= 0 || _cantidadDestino <= 0) return;

    setState(() => _procesando = true);

    // Ejecutar el intercambio en el portafolio
    final exito = await ref
        .read(portfolioProvider.notifier)
        .ejecutarIntercambio(
          simboloOrigen: _simboloOrigen,
          cantidadOrigen: cantidad,
          simboloDestino: _simboloDestino,
          cantidadDestino: _cantidadDestino,
        );

    if (exito) {
      // Registrar en el historial
      await ref
          .read(historyProvider.notifier)
          .registrarTransaccion(
            simboloOrigen: _simboloOrigen,
            simboloDestino: _simboloDestino,
            cantidadOrigen: cantidad,
            cantidadDestino: _cantidadDestino,
            tasaCambio: _tasaCambio,
          );

      setState(() {
        _intercambioExitoso = true;
        _procesando = false;
      });

      // Limpiar después de la animación de éxito
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _intercambioExitoso = false;
            _cantidadController.clear();
            _cantidadDestino = 0;
            _errorMessage = null;
          });
        }
      });
    } else {
      setState(() {
        _procesando = false;
        _errorMessage = 'Saldo insuficiente para realizar este intercambio';
      });
      
      // Limpiar error automáticamente después de unos segundos
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _errorMessage != null) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  void _showAssetSelector(BuildContext context, List<String> disponibles, ValueChanged<String> onSelected) {
    final portfolio = ref.read(portfolioProvider);
    final market = ref.read(marketProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar Activo',
                style: AppTypography.h3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: disponibles.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                  itemBuilder: (context, index) {
                    final s = disponibles[index];
                    final balance = portfolio.saldos[s] ?? 0.0;
                    final cryptoInfo = market.criptos.where((c) => c.shortSymbol == s).firstOrNull;

                    return InkWell(
                      onTap: () {
                        onSelected(s);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: ClipOval(child: _buildCryptoLogo(s, AppColors.primary)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s,
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    cryptoInfo?.name ?? (s == 'BS' ? 'Bolívares' : (s == 'PTR' ? 'Petros' : 'Token')),
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  balance.toStringAsFixed(4),
                                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  Formatters.usd(balance * _obtenerPrecioUsd(s, market)),
                                  style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 10),
                                ),
                              ],
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
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final saldoOrigen = portfolio.saldos[_simboloOrigen] ?? 0.0;

    // Lista de símbolos disponibles para intercambio
    final simbolosDisponibles = [...portfolio.saldos.keys];

    final history = ref.watch(historyProvider);
    final market = ref.watch(marketProvider);

    // Obtener info de las criptos seleccionadas para los paneles laterales
    final cryptoOrigen = market.criptos.where((c) => c.shortSymbol == _simboloOrigen).firstOrNull;
    final cryptoDestino = market.criptos.where((c) => c.shortSymbol == _simboloDestino).firstOrNull;
    final saldoDestino = portfolio.saldos[_simboloDestino] ?? 0.0;
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return Stack(
      children: [
        const AnimatedOrbsBackground(),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // El título de lo que estamos haciendo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intercambio de Activos',
                        style: AppTypography.h3.copyWith(color: AppColors.onSurface, fontSize: isMobile ? 18 : 22),
                      ),
                      Text(
                        'Convierte tus criptomonedas de forma instantánea',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile) _statusRow('RED', 'ONLINE', AppColors.success),
                ],
              ),
              const SizedBox(height: 16),

              if (isMobile)
                Column(
                  children: [
                    _buildSwapInterface(simbolosDisponibles, saldoOrigen, portfolio),
                    if (_errorMessage != null) _buildErrorBanner(),
                    const SizedBox(height: 12),
                    if (_tasaCambio > 0) _buildRateInfo(),
                    const SizedBox(height: 12),
                    if (_intercambioExitoso) 
                      _buildSuccessState()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _procesando ? null : _ejecutarIntercambio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _procesando
                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('REALIZAR INTERCAMBIO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _panel(
                      header: 'ACTIVO DE ORIGEN',
                      icon: Icons.upload_rounded,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildAssetInfo(_simboloOrigen, saldoOrigen, cryptoOrigen, market),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      header: 'ACTIVO DE DESTINO',
                      icon: Icons.download_rounded,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildAssetInfo(_simboloDestino, saldoDestino, cryptoDestino, market),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info de la moneda que vas a entregar
                    SizedBox(
                      width: 250,
                      child: Column(
                        children: [
                          _panel(
                            header: 'ACTIVO DE ORIGEN',
                            icon: Icons.upload_rounded,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildAssetInfo(_simboloOrigen, saldoOrigen, cryptoOrigen, market),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _panel(
                            header: 'HISTORIAL RECIENTE',
                            icon: Icons.history_rounded,
                            child: history.transacciones.isEmpty
                                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Sin actividad', style: TextStyle(fontSize: 10, color: Colors.grey))))
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: history.transacciones.length > 3 ? 3 : history.transacciones.length,
                                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                                    itemBuilder: (_, i) => _miniHistoryRow(history.transacciones[i]),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // El lugar donde pones los montos
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            children: [
                              _buildSwapInterface(simbolosDisponibles, saldoOrigen, portfolio),
                              
                              if (_errorMessage != null) _buildErrorBanner(),

                              const SizedBox(height: 12),
                              if (_tasaCambio > 0) _buildRateInfo(),
                              const SizedBox(height: 12),
                              if (_intercambioExitoso)
                                _buildSuccessState()
                              else
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _procesando ? null : _ejecutarIntercambio,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: _procesando
                                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('REALIZAR INTERCAMBIO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Info de la moneda que vas a recibir
                    SizedBox(
                      width: 250,
                      child: Column(
                        children: [
                          _panel(
                            header: 'ACTIVO DE DESTINO',
                            icon: Icons.download_rounded,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildAssetInfo(_simboloDestino, saldoDestino, cryptoDestino, market),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _panel(
                            header: 'SEGURIDAD',
                            icon: Icons.verified_user_rounded,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _statusRow('Protocolo', 'AES-256', AppColors.primary),
                                  const SizedBox(height: 8),
                                  _statusRow('Estado', 'Verificado', AppColors.success),
                                ],
                              ),
                            ),
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

  Widget _buildAssetInfo(String symbol, double saldo, CryptoModel? crypto, MarketState market) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(child: _buildCryptoLogo(symbol, AppColors.primary)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('Balance: ${saldo.toStringAsFixed(2)}', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _statusRow('Precio actual', Formatters.usd(_obtenerPrecioUsd(symbol, market)), AppColors.onSurface),
        if (crypto != null) ...[
          const SizedBox(height: 8),
          _statusRow('Cambio 24h', Formatters.percentage(crypto.priceChangePercent), crypto.priceChangePercent >= 0 ? AppColors.success : AppColors.error),
        ],
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().shake(duration: 400.ms),
    );
  }

  /// Construye la interfaz de intercambio agrupada
  Widget _buildSwapInterface(List<String> disponibles, double saldoOrigen, dynamic portfolio) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          _buildCryptoSelector(
            titulo: 'VENDES',
            simboloActual: _simboloOrigen,
            disponibles: disponibles,
            saldo: saldoOrigen,
            mostrarInput: true,
            onChanged: (s) {
              setState(() => _simboloOrigen = s);
              _calcularConversion();
            },
          ),
          const SizedBox(height: 4),
          _buildSwapDivider(),
          const SizedBox(height: 4),
          _buildCryptoSelector(
            titulo: 'RECIBES',
            simboloActual: _simboloDestino,
            disponibles: disponibles,
            saldo: portfolio.saldos[_simboloDestino] ?? 0.0,
            mostrarInput: false,
            cantidadCalculada: _cantidadDestino,
            onChanged: (s) {
              setState(() => _simboloDestino = s);
              _calcularConversion();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwapDivider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
        _buildSwapButton(),
      ],
    );
  }

  /// Selector de criptomoneda (origen o destino) con input de cantidad
  Widget _buildCryptoSelector({
    required String titulo,
    required String simboloActual,
    required List<String> disponibles,
    required double saldo,
    required bool mostrarInput,
    double cantidadCalculada = 0,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'SALDO: ${saldo.toStringAsFixed(4)}',
                style: TextStyle(
                  color: AppColors.onSurfaceMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Selector ultra compacto
              InkWell(
                onTap: () => _showAssetSelector(context, disponibles, onChanged),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: ClipOval(child: _buildCryptoLogo(simboloActual, AppColors.primary)),
                      ),
                      const SizedBox(width: 6),
                      Text(simboloActual, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.onSurfaceMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: mostrarInput
                    ? TextField(
                        controller: _cantidadController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: AppTypography.h3.copyWith(color: AppColors.onSurface, fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        cantidadCalculada > 0 ? cantidadCalculada.toStringAsFixed(4) : '0.00',
                        textAlign: TextAlign.right,
                        style: AppTypography.h3.copyWith(
                          color: cantidadCalculada > 0 ? AppColors.onSurface : Colors.grey,
                          fontSize: 18,
                        ),
                      ),
              ),
              if (mostrarInput) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _cantidadController.text = saldo.toString();
                    _calcularConversion();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'MÁX',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Botón circular de swap con animación de rotación
  Widget _buildSwapButton() {
    return InkWell(
      onTap: _intercambiarDireccion,
      borderRadius: BorderRadius.circular(20),
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 0.5).animate(
          CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceElevated,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Información de la tasa de cambio con countdown visual
  Widget _buildRateInfo() {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasa de cambio',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '1 $_simboloOrigen = ${_tasaCambio.toStringAsFixed(_tasaCambio >= 1 ? 4 : 8)} $_simboloDestino',
                  style: AppTypography.priceSmall.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Countdown circular
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _countdown / AppConstants.exchangeRateExpirySeconds,
                  strokeWidth: 2,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text(
                  '${_countdown}s',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de éxito después de un intercambio completado
  Widget _buildSuccessState() {
    return GlassmorphicCard(
          highlight: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 40,
                ),
              ).animate().scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Intercambio exitoso!',
                style: AppTypography.h3.copyWith(color: AppColors.success),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu saldo ha sido actualizado correctamente',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }

  // Elementos visuales auxiliares para logos y efectos de fondo


  /// Helper para construir el logo con múltiples fallbacks de extensión
  Widget _buildCryptoLogo(String symbol, Color color) {
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
                  style: TextStyle(
                    color: color,
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
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSelector(String symbol, List<String> disponibles, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: symbol,
          dropdownColor: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: disponibles.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(child: _buildCryptoLogo(s, AppColors.primary)),
                  ),
                  const SizedBox(width: 8),
                  Text(s, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }

  Widget _miniBalanceRow(String symbol, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(child: _buildCryptoLogo(symbol, AppColors.primary)),
          ),
          const SizedBox(width: 8),
          Text(
            symbol,
            style: TextStyle(color: AppColors.onSurface, fontSize: 10),
          ),
          const Spacer(),
          Text(
            amount.toStringAsFixed(amount >= 1 ? 2 : 4),
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _miniHistoryRow(dynamic tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.simboloOrigen} → ${tx.simboloDestino}',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                ),
                Text(
                  Formatters.dateTimeShort(tx.fecha),
                  style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 9),
                ),
              ],
            ),
          ),
          Text(
            '+${tx.cantidadDestino.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
