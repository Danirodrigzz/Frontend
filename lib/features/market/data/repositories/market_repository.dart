import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/crypto_model.dart';

/// Repositorio del mercado de criptomonedas.
/// Maneja las peticiones a la API de Binance y transforma las respuestas.
class MarketRepository {
  final ApiClient _apiClient;

  MarketRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Obtiene las estadísticas 24h de todas las criptos configuradas.
  Future<List<CryptoModel>> obtenerCriptomonedas() async {
    try {
      // Construir el formato de símbolos que Binance espera
      final symbolsParam = '[${AppConstants.tradingPairs.map((s) => '"$s"').join(',')}]';

      final data = await _apiClient.get(
        ApiConstants.ticker24h,
        queryParameters: {'symbols': symbolsParam},
      );

      if (data == null || data is! List) return [];

      final List<CryptoModel> criptos = [];

      for (final item in data) {
        final map = item as Map<String, dynamic>;
        final symbol = map['symbol'] as String? ?? '';

        if (!AppConstants.tradingPairs.contains(symbol)) continue;

        final shortSymbol = AppConstants.cryptoSymbols[symbol] ?? symbol;
        final name = AppConstants.cryptoNames[symbol] ?? symbol;

        criptos.add(CryptoModel.fromBinance24h(
          map,
          shortSymbol: shortSymbol,
          name: name,
        ));
      }

      return criptos;
    } catch (e) {
      throw Exception('Error al obtener datos del mercado: $e');
    }
  }

  /// Obtiene los datos de velas (klines) para un par específico.
  Future<List<KlineModel>> obtenerKlines({
    required String symbol,
    String interval = ApiConstants.interval1h,
    int limit = 48,
  }) async {
    try {
      final data = await _apiClient.get(
        ApiConstants.klines,
        queryParameters: {
          'symbol': symbol,
          'interval': interval,
          'limit': limit.toString(),
        },
      );

      if (data == null || data is! List) return [];

      return data
          .map((item) => KlineModel.fromBinance(item as List<dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener gráfico de precios: $e');
    }
  }
}
