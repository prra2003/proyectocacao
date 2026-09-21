import 'package:cacao_app/data/sync/api_apps_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lo que llega de la hoja de cálculo', () {
    test('una celda vacía es un valor ausente, no una cadena vacía', () {
      // Sin esto, un `deleted_at` vacío rompe DateTime.parse y tumba la
      // sincronización entera en la primera fila.
      final fila = ApiAppsScript.normalizar({
        'id': 'abc',
        'deleted_at': '',
        'observaciones': '',
      });

      expect(fila['id'], 'abc');
      expect(fila['deleted_at'], isNull);
      expect(fila['observaciones'], isNull);
    });

    test('las columnas de medida vuelven a ser números', () {
      final fila = ApiAppsScript.normalizar({
        'area_sembrada_ha': '2.5',
        'cantidad_kg': '125',
        'latitud': '6.88123',
      });

      expect(fila['area_sembrada_ha'], 2.5);
      expect(fila['cantidad_kg'], 125);
      expect(fila['latitud'], 6.88123);
    });

    test('el teléfono y el documento siguen siendo texto', () {
      // Convertirlos a número perdería el cero de la izquierda.
      final fila = ApiAppsScript.normalizar({
        'telefono': '3001234567',
        'numero_documento': '0987654321',
      });

      expect(fila['telefono'], '3001234567');
      expect(fila['numero_documento'], '0987654321');
    });
  });
}
