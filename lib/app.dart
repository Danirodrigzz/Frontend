import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// Widget raíz de la aplicación.
/// Configura MaterialApp con el tema oscuro premium, el router
/// y las configuraciones globales de la app.
class ChinchinApp extends ConsumerWidget {
  const ChinchinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el router reactivo que cambia con el estado de autenticación
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ChinChin Intercambio',
      debugShowCheckedModeBanner: false,

      // Tema oscuro premium personalizado
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Configuración del router
      routerConfig: router,
    );
  }
}
