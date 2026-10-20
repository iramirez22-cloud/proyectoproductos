import 'package:flutter_test/flutter_test.dart';
import 'package:miappgestorproductos/main.dart';

void main() {
  testWidgets('login muestra validación cuando los campos están vacíos', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu usuario'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });
}
