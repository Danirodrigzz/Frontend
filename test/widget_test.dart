// Esta es una prueba básica de widgets en Flutter.
//
// Para realizar una interacción con un widget en tu prueba, usa la utilidad
// WidgetTester en el paquete flutter_test. Por ejemplo, puedes enviar gestos
// de toque y desplazamiento. También puedes usar WidgetTester para encontrar
// widgets hijos en el árbol de widgets, leer texto y verificar que los valores
// de las propiedades de los widgets sean correctos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chinchin_exchange/main.dart';

void main() {
  testWidgets('Prueba de humo de incremento del contador', (WidgetTester tester) async {
    // Construir nuestra app y activar un frame.
    await tester.pumpWidget(const MyApp());

    // Verificar que nuestro contador comience en 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tocar el icono '+' y activar un frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verificar que nuestro contador se haya incrementado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
