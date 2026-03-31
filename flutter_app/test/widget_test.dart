import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('renderiza pantalla inicial del comparador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ComparadorApp());

    expect(find.text('Comparador GT'), findsOneWidget);
    expect(find.text('Compara precios en Walmart y La Torre'), findsOneWidget);
    expect(find.text('Buscar y comparar'), findsOneWidget);
  });
}
