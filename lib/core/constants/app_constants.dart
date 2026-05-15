/// Constantes generales de la aplicación.
/// Incluye valores fijos para monedas locales y configuración de la app.
class AppConstants {
  AppConstants._();

  // ── Valores fijos de moneda (según enunciado de la prueba) ───
  /// 1 PTR (Petro) = 60 USD
  static const double ptrToUsd = 60.0;

  /// 37.85 BS (Bolívares) = 1 USD
  static const double bsPerUsd = 37.85;

  // ── Intervalos de actualización ──────────────────────────────
  /// Intervalo de actualización de precios (en segundos)
  static const int refreshIntervalSeconds = 30;

  /// Tiempo que se muestra la tasa de cambio antes de expirar (en segundos)
  static const int exchangeRateExpirySeconds = 60;

  // ── Configuración de la app ──────────────────────────────────
  static const String appName = 'ChinChin Intercambio';
  static const String appVersion = '1.0.0';

  // ── Claves de almacenamiento local ───────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String balancesKey = 'user_balances';
  static const String historyKey = 'transaction_history';
  static const String settingsKey = 'app_settings';

  // ── Pares de criptomonedas a mostrar ─────────────────────────
  /// Símbolos principales que se consultan contra USDT en Binance
  static const List<String> tradingPairs = [
    'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'XRPUSDT',
    'ADAUSDT', 'DOGEUSDT', 'DOTUSDT', 'AVAXUSDT', 'LINKUSDT',
    'MATICUSDT', 'UNIUSDT', 'ATOMUSDT', 'LTCUSDT', 'NEARUSDT',
  ];

  /// Mapeo de símbolo del par a nombre legible de la criptomoneda
  static const Map<String, String> cryptoNames = {
    'BTCUSDT': 'Bitcoin',
    'ETHUSDT': 'Ethereum',
    'BNBUSDT': 'BNB',
    'SOLUSDT': 'Solana',
    'XRPUSDT': 'XRP',
    'ADAUSDT': 'Cardano',
    'DOGEUSDT': 'Dogecoin',
    'DOTUSDT': 'Polkadot',
    'AVAXUSDT': 'Avalanche',
    'LINKUSDT': 'Chainlink',
    'MATICUSDT': 'Polygon',
    'UNIUSDT': 'Uniswap',
    'ATOMUSDT': 'Cosmos',
    'LTCUSDT': 'Litecoin',
    'NEARUSDT': 'NEAR Protocol',
  };

  /// Símbolo corto de cada criptomoneda (sin el USDT)
  static const Map<String, String> cryptoSymbols = {
    'BTCUSDT': 'BTC',
    'ETHUSDT': 'ETH',
    'BNBUSDT': 'BNB',
    'SOLUSDT': 'SOL',
    'XRPUSDT': 'XRP',
    'ADAUSDT': 'ADA',
    'DOGEUSDT': 'DOGE',
    'DOTUSDT': 'DOT',
    'AVAXUSDT': 'AVAX',
    'LINKUSDT': 'LINK',
    'MATICUSDT': 'MATIC',
    'UNIUSDT': 'UNI',
    'ATOMUSDT': 'ATOM',
    'LTCUSDT': 'LTC',
    'NEARUSDT': 'NEAR',
  };

  // ── Saldos iniciales del usuario ─────────────────────────────
  /// Saldos estáticos que el usuario tiene al comenzar
  static const Map<String, double> initialBalances = {
    'BTC': 0.5,
    'ETH': 2.0,
    'BNB': 10.0,
    'USDT': 5000.0,
    'SOL': 15.0,
    'ADA': 1000.0,
    'XRP': 500.0,
    'DOGE': 5000.0,
    'DOT': 50.0,
    'AVAX': 30.0,
    'LINK': 100.0,
    'MATIC': 2000.0,
    'UNI': 80.0,
    'ATOM': 40.0,
    'LTC': 5.0,
    'NEAR': 200.0,
    'PTR': 100.0,
    'BS': 50000.0,
  };
}
