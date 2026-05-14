import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00BFA6); 
  static const Color primaryLight = Color(0xFF33CCB8);
  static const Color accent = Color(0xFF00BFA6); // Añadido para compatibilidad
  
  static const Color background = Color(0xFF0B0E11); 
  static const Color surface = Color(0xFF1E2329);    
  static const Color surfaceVariant = Color(0xFF2B3139); 
  static const Color surfaceElevated = Color(0xFF474D57); 

  static const Color onSurface = Color(0xFFEAECEF);  
  static const Color onSurfaceVariant = Color(0xFFB7BDC6); 
  static const Color onSurfaceMuted = Color(0xFF848E9C);   

  static const Color border = Color(0xFF2B3139);
  static const Color divider = Color(0xFF2B3139);

  static const Color success = Color(0xFF0ECB81); 
  static const Color error = Color(0xFFF6465D);   
  static const Color warning = Color(0xFFF0B90B);
  static const Color info = Color(0xFF38BDF8);
  static const Color onPrimary = Color(0xFF0B0E11);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA6), Color(0xFF00E6C4)],
  );
}
