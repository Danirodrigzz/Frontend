import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

/// Punto de entrada de la aplicación ChinChin Intercambio.
/// Inicializa Flutter, envuelve la app con ProviderScope de Riverpod
/// para habilitar la gestión de estado reactiva en toda la app.
void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización para formateo de fechas
  await initializeDateFormatting('es_ES', null);

  runApp(
    // ProviderScope es el contenedor raíz de Riverpod
    // que permite que todos los providers sean accesibles
    const ProviderScope(
      child: ChinchinApp(),
    ),
  );
}
