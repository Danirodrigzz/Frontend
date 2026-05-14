import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Punto de entrada de la aplicación ChinChin Exchange.
/// Inicializa Flutter, envuelve la app con ProviderScope de Riverpod
/// para habilitar la gestión de estado reactiva en toda la app.
void main() {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope es el contenedor raíz de Riverpod
    // que permite que todos los providers sean accesibles
    const ProviderScope(
      child: ChinchinApp(),
    ),
  );
}
