import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Funciones de formateo para monedas, porcentajes y fechas.
/// Centraliza el formateo para mantener consistencia visual en toda la app.
class Formatters {
  Formatters._();

  // ── Formato de moneda USD ────────────────────────────────────
  static final _usdFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'en_US',
  );

  /// Formatea un valor como USD (ej: \$1,234.56)
  static String usd(double value) => _usdFormat.format(value);

  /// Formatea un precio cripto con decimales dinámicos
  /// Para precios altos (>100) usa 2 decimales, para bajos usa hasta 6
  static String cryptoPrice(double value) {
    if (value >= 1000) {
      return NumberFormat('#,##0.00', 'en_US').format(value);
    } else if (value >= 1) {
      return NumberFormat('#,##0.0000', 'en_US').format(value);
    } else {
      return NumberFormat('#,##0.000000', 'en_US').format(value);
    }
  }

  // ── Formato de Petro y Bolívares ─────────────────────────────
  /// Convierte USD a PTR y formatea
  static String usdToPtr(double usdValue) {
    final ptr = usdValue / AppConstants.ptrToUsd;
    return '${NumberFormat('#,##0.00', 'en_US').format(ptr)} PTR';
  }

  /// Convierte USD a BS y formatea
  static String usdToBs(double usdValue) {
    final bs = usdValue * AppConstants.bsPerUsd;
    return '${NumberFormat('#,##0.00', 'en_US').format(bs)} Bs';
  }

  // ── Formato de porcentaje ────────────────────────────────────
  /// Formatea un porcentaje con signo (ej: +2.45% o -1.23%)
  static String percentage(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  // ── Formato de volumen ───────────────────────────────────────
  /// Formatea volumen con sufijos K, M, B para legibilidad
  static String volume(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  // ── Formato de cantidad cripto ───────────────────────────────
  /// Formatea una cantidad de criptomoneda (ej: 0.00054321 BTC)
  static String cryptoAmount(double value, String symbol) {
    if (value >= 1000) {
      return '${NumberFormat('#,##0.00', 'en_US').format(value)} $symbol';
    } else if (value >= 1) {
      return '${NumberFormat('0.0000', 'en_US').format(value)} $symbol';
    } else {
      return '${NumberFormat('0.00000000', 'en_US').format(value)} $symbol';
    }
  }

  // ── Formato de fecha y hora ──────────────────────────────────
  /// Formato completo: 14 May 2026, 17:30
  static String dateTimeFull(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'es_ES').format(date);
  }

  /// Formato corto: 14/05/26 17:30
  static String dateTimeShort(DateTime date) {
    return DateFormat('dd/MM/yy HH:mm').format(date);
  }

  /// Solo hora: 17:30:45
  static String timeOnly(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  /// Tiempo relativo: "hace 5 min", "hace 2h", etc.
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}
