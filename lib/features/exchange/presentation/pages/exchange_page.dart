import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../market/presentation/providers/market_provider.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';

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
    final cantidad = double.tryParse(
      _cantidadController.text.replaceAll(',', '.'),
    ) ?? 0;

    if (cantidad <= 0 || _cantidadDestino <= 0) return;

    setState(() => _procesando = true);

    // Ejecutar el intercambio en el portafolio
    final exito = await ref.read(portfolioProvider.notifier).ejecutarIntercambio(
      simboloOrigen: _simboloOrigen,
      cantidadOrigen: cantidad,
      simboloDestino: _simboloDestino,
      cantidadDestino: _cantidadDestino,
    );

    if (exito) {
      // Registrar en el historial
      await ref.read(historyProvider.notifier).registrarTransaccion(
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
          });
        }
      });
    } else {
      setState(() => _procesando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saldo insuficiente para este intercambio'),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final saldoOrigen = portfolio.saldos[_simboloOrigen] ?? 0.0;

    // Lista de símbolos disponibles para intercambio
    final simbolosDisponibles = [
      ...portfolio.saldos.keys,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intercambiar',
            style: AppTypography.h2.copyWith(color: AppColors.onSurface),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'Intercambia entre criptomonedas de forma instantánea',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Panel de intercambio centrado
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // ── Cripto origen ──────────────────────────
                  _buildCryptoSelector(
                    titulo: 'De',
                    simboloActual: _simboloOrigen,
                    disponibles: simbolosDisponibles,
                    saldo: saldoOrigen,
                    mostrarInput: true,
                    onChanged: (s) {
                      setState(() => _simboloOrigen = s);
                      _calcularConversion();
                    },
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideX(begin: -0.1, end: 0, delay: 200.ms),

                  const SizedBox(height: 8),

                  // ── Botón swap ─────────────────────────────
                  _buildSwapButton(),

                  const SizedBox(height: 8),

                  // ── Cripto destino ─────────────────────────
                  _buildCryptoSelector(
                    titulo: 'A',
                    simboloActual: _simboloDestino,
                    disponibles: simbolosDisponibles,
                    saldo: portfolio.saldos[_simboloDestino] ?? 0.0,
                    mostrarInput: false,
                    cantidadCalculada: _cantidadDestino,
                    onChanged: (s) {
                      setState(() => _simboloDestino = s);
                      _calcularConversion();
                    },
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideX(begin: 0.1, end: 0, delay: 300.ms),

                  const SizedBox(height: 16),

                  // ── Tasa de cambio y countdown ────────────
                  if (_tasaCambio > 0) _buildRateInfo(),

                  const SizedBox(height: 20),

                  // ── Botón de ejecutar o estado de éxito ───
                  if (_intercambioExitoso)
                    _buildSuccessState()
                  else
                    GradientButton(
                      text: 'Ejecutar Intercambio',
                      icon: Icons.swap_horiz_rounded,
                      isLoading: _procesando,
                      onPressed: _procesando ? null : _ejecutarIntercambio,
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
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
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                titulo,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Saldo: ${saldo.toStringAsFixed(saldo >= 1 ? 4 : 8)} $simboloActual',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Dropdown de selección de cripto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: simboloActual,
                    dropdownColor: AppColors.surfaceElevated,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.onSurfaceVariant, size: 20),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    items: disponibles.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) onChanged(v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Campo de cantidad o cantidad calculada
              Expanded(
                child: mostrarInput
                    ? TextField(
                        controller: _cantidadController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: AppTypography.priceMedium.copyWith(
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: AppTypography.priceMedium.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        cantidadCalculada > 0
                            ? cantidadCalculada.toStringAsFixed(
                                cantidadCalculada >= 1 ? 4 : 8)
                            : '0.00',
                        style: AppTypography.priceMedium.copyWith(
                          color: cantidadCalculada > 0
                              ? AppColors.onSurface
                              : AppColors.onSurfaceMuted,
                        ),
                        textAlign: TextAlign.right,
                      ),
              ),

              // Botón MAX para usar todo el saldo
              if (mostrarInput)
                InkWell(
                  onTap: () {
                    _cantidadController.text = saldo.toString();
                    _calcularConversion();
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MAX',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Botón circular de swap con animación de rotación
  Widget _buildSwapButton() {
    return Center(
      child: InkWell(
        onTap: _intercambiarDireccion,
        borderRadius: BorderRadius.circular(24),
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 0.5).animate(
            CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          delay: 250.ms,
          curve: Curves.elasticOut,
        );
  }

  /// Información de la tasa de cambio con countdown visual
  Widget _buildRateInfo() {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
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
                  '1 $_simboloOrigen = ${_tasaCambio.toStringAsFixed(
                    _tasaCambio >= 1 ? 4 : 8)} $_simboloDestino',
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
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms);
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
          )
              .animate()
              .scale(
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
}
