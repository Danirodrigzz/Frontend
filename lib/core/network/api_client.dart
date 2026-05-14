import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Cliente HTTP para la API de Binance usando el paquete http.
/// En Flutter Web, 'http' tiene mejor soporte CORS que Dio directo.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal();

  /// GET genérico que retorna el body parseado como JSON
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    // Construir la URL completa con parámetros
    final uri = Uri.parse('${ApiConstants.binanceBaseUrl}$path').replace(
      queryParameters: queryParameters,
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
