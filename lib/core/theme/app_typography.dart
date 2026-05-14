import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estilos tipográficos de la aplicación.
/// Usa Inter para textos generales y JetBrains Mono para datos numéricos.
class AppTypography {
  AppTypography._();

  // ── Encabezados ──────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle get h4 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ── Cuerpo de texto ──────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Etiquetas (labels) ───────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // ── Datos numéricos / financieros ────────────────────────────
  /// Para precios, saldos y valores monetarios
  static TextStyle get priceLarge => GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get priceMedium => GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get priceSmall => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Para porcentajes de cambio (24h, etc.)
  static TextStyle get percentage => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ── Botones ──────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );
}
