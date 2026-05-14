import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';

/// Estado del historial de transacciones.
class HistoryState {
  final List<TransactionModel> transacciones;
  final bool estaCargando;

  const HistoryState({
    this.transacciones = const [],
    this.estaCargando = false,
  });

  HistoryState copyWith({
    List<TransactionModel>? transacciones,
    bool? estaCargando,
  }) {
    return HistoryState(
      transacciones: transacciones ?? this.transacciones,
      estaCargando: estaCargando ?? this.estaCargando,
    );
  }
}

/// Provider del historial de transacciones.
/// Gestiona el almacenamiento y recuperación de transacciones.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());

  /// Carga el historial de transacciones desde el almacenamiento local
  Future<void> cargarHistorial() async {
    state = state.copyWith(estaCargando: true);

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.historyKey);

    if (data != null) {
      final lista = (jsonDecode(data) as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Ordenar por fecha más reciente primero
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));

      state = state.copyWith(transacciones: lista, estaCargando: false);
    } else {
      state = state.copyWith(estaCargando: false);
    }
  }

  /// Registra una nueva transacción en el historial
  Future<void> registrarTransaccion({
    required String simboloOrigen,
    required String simboloDestino,
    required double cantidadOrigen,
    required double cantidadDestino,
    required double tasaCambio,
  }) async {
    final nuevaTransaccion = TransactionModel(
      id: const Uuid().v4(),
      simboloOrigen: simboloOrigen,
      simboloDestino: simboloDestino,
      cantidadOrigen: cantidadOrigen,
      cantidadDestino: cantidadDestino,
      tasaCambio: tasaCambio,
      fecha: DateTime.now(),
    );

    final transaccionesActualizadas = [
      nuevaTransaccion,
      ...state.transacciones,
    ];

    state = state.copyWith(transacciones: transaccionesActualizadas);
    await _guardarHistorial();
  }

  /// Persiste el historial en SharedPreferences
  Future<void> _guardarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(
      state.transacciones.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(AppConstants.historyKey, data);
  }
}
