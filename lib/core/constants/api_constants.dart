/// Constantes de las APIs externas utilizadas en la aplicación.
class ApiConstants {
  ApiConstants._();

  // ── Binance API (pública, sin autenticación) ─────────────────
  static const String binanceBaseUrl = 'https://api.binance.com';

  /// Precio actual de un par de criptomonedas
  /// Ejemplo: /api/v3/ticker/price?symbol=BTCUSDT
  static const String tickerPrice = '/api/v3/ticker/price';

  /// Estadísticas de las últimas 24 horas
  /// Ejemplo: /api/v3/ticker/24hr?symbol=BTCUSDT
  static const String ticker24h = '/api/v3/ticker/24hr';

  /// Datos de velas (klines) para gráficos
  /// Ejemplo: /api/v3/klines?symbol=BTCUSDT&interval=1h&limit=24
  static const String klines = '/api/v3/klines';

  // ── Intervalos de velas disponibles ──────────────────────────
  static const String interval1h = '1h';
  static const String interval4h = '4h';
  static const String interval1d = '1d';
  static const String interval1w = '1w';
}
