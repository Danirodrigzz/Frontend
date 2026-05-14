import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/crypto_model.dart';
import '../../data/repositories/market_repository.dart';

/// Enumeración para los criterios de ordenamiento disponibles
enum OrdenCripto {
  nombreAsc,
  nombreDesc,
  precioAsc,
  precioDesc,
  cambioAsc,
  cambioDesc,
  volumenDesc,
}

/// Estado del mercado de criptomonedas.
/// Contiene la lista de criptos, filtros activos y estado de carga.
class MarketState {
  final List<CryptoModel> criptos;
  final List<CryptoModel> criptosFiltradas;
  final bool estaCargando;
  final String? error;
  final String busqueda;
  final OrdenCripto orden;
  final int segundosParaRefresh;

  const MarketState({
    this.criptos = const [],
    this.criptosFiltradas = const [],
    this.estaCargando = false,
    this.error,
    this.busqueda = '',
    this.orden = OrdenCripto.volumenDesc,
    this.segundosParaRefresh = AppConstants.refreshIntervalSeconds,
  });

  MarketState copyWith({
    List<CryptoModel>? criptos,
    List<CryptoModel>? criptosFiltradas,
    bool? estaCargando,
    String? error,
    String? busqueda,
    OrdenCripto? orden,
    int? segundosParaRefresh,
  }) {
    return MarketState(
      criptos: criptos ?? this.criptos,
      criptosFiltradas: criptosFiltradas ?? this.criptosFiltradas,
      estaCargando: estaCargando ?? this.estaCargando,
      error: error,
      busqueda: busqueda ?? this.busqueda,
      orden: orden ?? this.orden,
      segundosParaRefresh: segundosParaRefresh ?? this.segundosParaRefresh,
    );
  }
}

/// Provider del repositorio del mercado
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository();
});

/// Provider principal del mercado de criptomonedas.
/// Gestiona la carga, filtrado, ordenamiento y auto-actualización.
final marketProvider = StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  return MarketNotifier(ref.read(marketRepositoryProvider));
});

class MarketNotifier extends StateNotifier<MarketState> {
  final MarketRepository _repository;
  Timer? _timerRefresh;
  Timer? _timerCountdown;

  MarketNotifier(this._repository) : super(const MarketState());

  /// Carga inicial de las criptomonedas y arranca el auto-refresh
  Future<void> cargarCriptos() async {
    state = state.copyWith(estaCargando: true, error: null);

    try {
      final criptos = await _repository.obtenerCriptomonedas();
      state = state.copyWith(
        criptos: criptos,
        estaCargando: false,
      );

      // Aplicar filtros y orden actual
      _aplicarFiltrosYOrden();

      // Iniciar auto-actualización cada 30 segundos
      _iniciarAutoRefresh();
    } catch (e) {
      state = state.copyWith(
        estaCargando: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Actualiza los precios sin mostrar el indicador de carga principal
  Future<void> actualizarPrecios() async {
    try {
      final criptos = await _repository.obtenerCriptomonedas();
      state = state.copyWith(
        criptos: criptos,
        segundosParaRefresh: AppConstants.refreshIntervalSeconds,
      );
      _aplicarFiltrosYOrden();
    } catch (e) {
      // Si falla la actualización silenciosa, no mostramos error
      // Los datos anteriores siguen siendo válidos
    }
  }

  /// Aplica un texto de búsqueda para filtrar las criptos
  void buscar(String texto) {
    state = state.copyWith(busqueda: texto);
    _aplicarFiltrosYOrden();
  }

  /// Cambia el criterio de ordenamiento
  void ordenar(OrdenCripto nuevoOrden) {
    state = state.copyWith(orden: nuevoOrden);
    _aplicarFiltrosYOrden();
  }

  /// Filtra y ordena la lista de criptos según los criterios activos
  void _aplicarFiltrosYOrden() {
    var resultado = List<CryptoModel>.from(state.criptos);

    // Aplicar búsqueda por nombre o símbolo
    if (state.busqueda.isNotEmpty) {
      final termino = state.busqueda.toLowerCase();
      resultado = resultado.where((c) {
        return c.name.toLowerCase().contains(termino) ||
            c.shortSymbol.toLowerCase().contains(termino);
      }).toList();
    }

    // Aplicar ordenamiento
    switch (state.orden) {
      case OrdenCripto.nombreAsc:
        resultado.sort((a, b) => a.name.compareTo(b.name));
      case OrdenCripto.nombreDesc:
        resultado.sort((a, b) => b.name.compareTo(a.name));
      case OrdenCripto.precioAsc:
        resultado.sort((a, b) => a.price.compareTo(b.price));
      case OrdenCripto.precioDesc:
        resultado.sort((a, b) => b.price.compareTo(a.price));
      case OrdenCripto.cambioAsc:
        resultado.sort((a, b) => a.priceChangePercent.compareTo(b.priceChangePercent));
      case OrdenCripto.cambioDesc:
        resultado.sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));
      case OrdenCripto.volumenDesc:
        resultado.sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));
    }

    state = state.copyWith(criptosFiltradas: resultado);
  }

  /// Inicia el timer de auto-actualización cada 30 segundos
  void _iniciarAutoRefresh() {
    _timerRefresh?.cancel();
    _timerCountdown?.cancel();

    // Timer principal que actualiza los datos
    _timerRefresh = Timer.periodic(
      const Duration(seconds: AppConstants.refreshIntervalSeconds),
      (_) => actualizarPrecios(),
    );

    // Timer del countdown visual (cada segundo)
    _timerCountdown = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        final nuevoValor = state.segundosParaRefresh - 1;
        if (nuevoValor >= 0) {
          state = state.copyWith(segundosParaRefresh: nuevoValor);
        }
      },
    );
  }

  /// Detiene los timers de auto-actualización
  void detenerAutoRefresh() {
    _timerRefresh?.cancel();
    _timerCountdown?.cancel();
  }

  @override
  void dispose() {
    _timerRefresh?.cancel();
    _timerCountdown?.cancel();
    super.dispose();
  }
}
