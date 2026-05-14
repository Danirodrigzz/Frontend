import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

/// Estado del portafolio del usuario.
/// Contiene los saldos de todas las criptomonedas que posee.
class PortfolioState {
  final Map<String, double> saldos;
  final bool estaCargando;

  const PortfolioState({
    this.saldos = const {},
    this.estaCargando = false,
  });

  PortfolioState copyWith({
    Map<String, double>? saldos,
    bool? estaCargando,
  }) {
    return PortfolioState(
      saldos: saldos ?? this.saldos,
      estaCargando: estaCargando ?? this.estaCargando,
    );
  }
}

/// Provider del portafolio del usuario.
/// Gestiona la carga y actualización de saldos almacenados localmente.
final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  return PortfolioNotifier();
});

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier() : super(const PortfolioState());

  /// Carga los saldos del usuario desde el almacenamiento local
  Future<void> cargarSaldos() async {
    state = state.copyWith(estaCargando: true);

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.balancesKey);

    if (data != null) {
      final mapa = (jsonDecode(data) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      state = state.copyWith(saldos: mapa, estaCargando: false);
    } else {
      // Si no hay saldos guardados, usar los iniciales
      state = state.copyWith(
        saldos: Map<String, double>.from(AppConstants.initialBalances),
        estaCargando: false,
      );
      await _guardarSaldos();
    }
  }

  /// Obtiene el saldo de una criptomoneda específica
  double obtenerSaldo(String simbolo) {
    return state.saldos[simbolo] ?? 0.0;
  }

  /// Actualiza el saldo de una criptomoneda (resta/suma)
  Future<void> actualizarSaldo(String simbolo, double nuevoSaldo) async {
    final saldosActualizados = Map<String, double>.from(state.saldos);
    saldosActualizados[simbolo] = nuevoSaldo;
    state = state.copyWith(saldos: saldosActualizados);
    await _guardarSaldos();
  }

  /// Ejecuta un intercambio: resta del origen y suma al destino
  Future<bool> ejecutarIntercambio({
    required String simboloOrigen,
    required double cantidadOrigen,
    required String simboloDestino,
    required double cantidadDestino,
  }) async {
    final saldoOrigen = obtenerSaldo(simboloOrigen);

    // Verificar que haya saldo suficiente
    if (saldoOrigen < cantidadOrigen) return false;

    final saldosActualizados = Map<String, double>.from(state.saldos);
    saldosActualizados[simboloOrigen] = saldoOrigen - cantidadOrigen;
    saldosActualizados[simboloDestino] =
        (saldosActualizados[simboloDestino] ?? 0) + cantidadDestino;

    state = state.copyWith(saldos: saldosActualizados);
    await _guardarSaldos();
    return true;
  }

  /// Persiste los saldos actuales en SharedPreferences
  Future<void> _guardarSaldos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.balancesKey, jsonEncode(state.saldos));
  }
}
