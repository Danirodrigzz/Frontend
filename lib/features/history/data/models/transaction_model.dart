import 'dart:convert';

/// Modelo de una transacción de intercambio de criptomonedas.
/// Registra todos los detalles del intercambio para el historial.
class TransactionModel {
  final String id;
  final String simboloOrigen;
  final String simboloDestino;
  final double cantidadOrigen;
  final double cantidadDestino;
  final double tasaCambio;
  final DateTime fecha;

  const TransactionModel({
    required this.id,
    required this.simboloOrigen,
    required this.simboloDestino,
    required this.cantidadOrigen,
    required this.cantidadDestino,
    required this.tasaCambio,
    required this.fecha,
  });

  /// Crea la instancia desde un mapa JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      simboloOrigen: json['simboloOrigen'] as String,
      simboloDestino: json['simboloDestino'] as String,
      cantidadOrigen: (json['cantidadOrigen'] as num).toDouble(),
      cantidadDestino: (json['cantidadDestino'] as num).toDouble(),
      tasaCambio: (json['tasaCambio'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  /// Convierte la instancia a mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simboloOrigen': simboloOrigen,
      'simboloDestino': simboloDestino,
      'cantidadOrigen': cantidadOrigen,
      'cantidadDestino': cantidadDestino,
      'tasaCambio': tasaCambio,
      'fecha': fecha.toIso8601String(),
    };
  }

  /// Serializa a JSON string para almacenamiento
  String toJsonString() => jsonEncode(toJson());
}
