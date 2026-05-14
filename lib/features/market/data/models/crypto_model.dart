/// Modelo que representa una criptomoneda con sus datos de mercado.
/// Contiene precio actual, cambios 24h, volumen y datos para gráficos.
class CryptoModel {
  final String symbol;       // Símbolo del par (ej: BTCUSDT)
  final String shortSymbol;  // Símbolo corto (ej: BTC)
  final String name;         // Nombre legible (ej: Bitcoin)
  final double price;        // Precio actual en USD
  final double priceChange;  // Cambio de precio absoluto 24h
  final double priceChangePercent; // Cambio porcentual 24h
  final double high24h;      // Precio máximo 24h
  final double low24h;       // Precio mínimo 24h
  final double volume;       // Volumen de trading 24h
  final double quoteVolume;  // Volumen en la moneda de cotización
  final List<double> sparkline; // Datos del mini-gráfico sparkline

  const CryptoModel({
    required this.symbol,
    required this.shortSymbol,
    required this.name,
    required this.price,
    this.priceChange = 0,
    this.priceChangePercent = 0,
    this.high24h = 0,
    this.low24h = 0,
    this.volume = 0,
    this.quoteVolume = 0,
    this.sparkline = const [],
  });

  /// Crea una instancia desde la respuesta de Binance /ticker/24hr
  factory CryptoModel.fromBinance24h(
    Map<String, dynamic> json, {
    required String shortSymbol,
    required String name,
    List<double> sparkline = const [],
  }) {
    return CryptoModel(
      symbol: json['symbol'] as String? ?? '',
      shortSymbol: shortSymbol,
      name: name,
      price: double.tryParse(json['lastPrice']?.toString() ?? '0') ?? 0,
      priceChange: double.tryParse(json['priceChange']?.toString() ?? '0') ?? 0,
      priceChangePercent: double.tryParse(json['priceChangePercent']?.toString() ?? '0') ?? 0,
      high24h: double.tryParse(json['highPrice']?.toString() ?? '0') ?? 0,
      low24h: double.tryParse(json['lowPrice']?.toString() ?? '0') ?? 0,
      volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0,
      quoteVolume: double.tryParse(json['quoteVolume']?.toString() ?? '0') ?? 0,
      sparkline: sparkline,
    );
  }

  /// Indica si el precio ha subido en las últimas 24 horas
  bool get estaSuiendo => priceChangePercent >= 0;

  /// Crea una copia con campos actualizados (útil para actualizar precios)
  CryptoModel copyWith({
    double? price,
    double? priceChange,
    double? priceChangePercent,
    double? high24h,
    double? low24h,
    double? volume,
    double? quoteVolume,
    List<double>? sparkline,
  }) {
    return CryptoModel(
      symbol: symbol,
      shortSymbol: shortSymbol,
      name: name,
      price: price ?? this.price,
      priceChange: priceChange ?? this.priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume: volume ?? this.volume,
      quoteVolume: quoteVolume ?? this.quoteVolume,
      sparkline: sparkline ?? this.sparkline,
    );
  }
}

/// Modelo para un punto de datos del gráfico de velas (kline)
class KlineModel {
  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const KlineModel({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Crea una instancia desde la respuesta de klines de Binance.
  /// Binance retorna arrays con formato: [openTime, open, high, low, close, volume, ...]
  factory KlineModel.fromBinance(List<dynamic> data) {
    return KlineModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(data[0] as int),
      open: double.tryParse(data[1].toString()) ?? 0,
      high: double.tryParse(data[2].toString()) ?? 0,
      low: double.tryParse(data[3].toString()) ?? 0,
      close: double.tryParse(data[4].toString()) ?? 0,
      volume: double.tryParse(data[5].toString()) ?? 0,
    );
  }
}
