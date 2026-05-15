import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Decoraciones reutilizables para la interfaz.
/// Glassmorphism, sombras con glow, contenedores elevados, etc.
class AppDecorations {
  AppDecorations._();

  // Glassmorphism premium
  /// Decoración base de vidrio esmerilado con tinte violeta
  static BoxDecoration glass({
    double borderRadius = 16,
    bool highlight = false,
  }) {
    return BoxDecoration(
      gradient: AppColors.glassGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.06),
        width: 1,
      ),
    );
  }

  /// Decoración de vidrio con borde cyan para tarjetas activas
  static BoxDecoration glassAccent({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x1506D6A0),
          Color(0x0AFFFFFF),
          Color(0x088B5CF6),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.accent.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }

  // Sombras con glow
  /// Glow violeta para elementos primarios
  static List<BoxShadow> glowPrimary({double intensity = 0.3}) {
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: intensity),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Glow cyan para elementos de acento
  static List<BoxShadow> glowAccent({double intensity = 0.25}) {
    return [
      BoxShadow(
        color: AppColors.accent.withValues(alpha: intensity),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Glow suave genérico
  static List<BoxShadow> glowSoft = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  // Contenedores de superficie
  /// Contenedor de superficie elevada con borde sutil
  static BoxDecoration surfaceCard({double borderRadius = 14}) {
    return BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.5),
        width: 1,
      ),
    );
  }

  /// Input field decoración
  static BoxDecoration inputDecoration({bool focused = false}) {
    return BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: focused
            ? AppColors.primary.withValues(alpha: 0.6)
            : AppColors.border,
        width: focused ? 1.5 : 1,
      ),
    );
  }

  // Filtros de blur
  /// Filtro de blur para glassmorphism estándar
  static ImageFilter get blurFilter => ImageFilter.blur(sigmaX: 14, sigmaY: 14);

  /// Filtro de blur más suave
  static ImageFilter get blurSoft => ImageFilter.blur(sigmaX: 8, sigmaY: 8);
}
