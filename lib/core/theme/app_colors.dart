import 'package:flutter/material.dart';

/// Paleta de colores estilo dashboard de trading ChinChin.
/// Fondo muy oscuro con acentos cyan/turquesa brillantes y glow.
class AppColors {
  AppColors._();

  // ── Identidad ChinChin ──────────────────────────────────────
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryLight = Color(0xFF33E0BE);
  static const Color primaryDark = Color(0xFF00A688);
  static const Color accent = Color(0xFF00D4AA);
  static const Color onPrimary = Color(0xFF0A0E17);

  // ── Fondos ──────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFF1A2236);
  static const Color surfaceElevated = Color(0xFF1E2A3F);
  static const Color surfaceHeader = Color(0xFF0D1220);

  // ── Texto ───────────────────────────────────────────────────
  static const Color textDark = Color(0xFF0A0E17);
  static const Color onSurface = Color(0xFFE8ECF1);
  static const Color onSurfaceVariant = Color(0xFF8899AA);
  static const Color onSurfaceMuted = Color(0xFF5A6A7A);

  // ── Bordes y líneas ─────────────────────────────────────────
  static const Color border = Color(0xFF1C2A3D);
  static const Color borderGlow = Color(0xFF00D4AA);
  static const Color divider = Color(0xFF1C2A3D);

  // ── Estados ─────────────────────────────────────────────────
  static const Color success = Color(0xFF00E68A);
  static const Color error = Color(0xFFFF4D6A);
  static const Color warning = Color(0xFFFFB020);
  static const Color info = Color(0xFF3BA0FF);

  // ── Gradientes ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Color(0xFF0F1624)],
  );
}
