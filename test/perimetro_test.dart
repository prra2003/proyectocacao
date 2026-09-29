import 'package:cacao_app/ui/widgets/perimetro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

/// El lote es parte de la finca. Si alguien lo marca en otro municipio es un
/// error de dedo, y echa a perder el dato justo para lo que más sirve:
/// demostrarle al comprador de dónde salió el cacao.
void main() {
  // El punto real de La Esperanza, en San Vicente de Chucurí.
  const finca = LatLng(6.88, -73.41);

  group('el radio sale de las hectáreas', () {
    test('una finca chica no baja del mínimo', () {
      // Media hectárea son 40 m de radio exacto: demasiado poco, y el GPS
      // mismo se equivoca más que eso.
      expect(radioPermitidoMetros(0.5), 300);
      expect(radioPermitidoMetros(0), 300);
    });

    test('crece con el tamaño de la finca', () {
      // 10 ha caben en un círculo de 178 m; con la holgura, unos 535.
      final diez = radioPermitidoMetros(10);
      expect(diez, greaterThan(500));
      expect(diez, lessThan(600));
      expect(radioPermitidoMetros(40), greaterThan(diez));
    });

    test('no se dispara por grande que sea', () {
      expect(radioPermitidoMetros(100000), 5000);
    });
  });

  group('dentro o fuera', () {
    test('un lote al lado de la casa entra', () {
      expect(
        dentroDelPerimetro(
          punto: const LatLng(6.8805, -73.4105),
          centroFinca: finca,
          hectareas: 12,
        ),
        isTrue,
      );
    });

    test('un lote en otro municipio no entra', () {
      // Rionegro, Santander: a unos 50 km.
      expect(
        dentroDelPerimetro(
          punto: const LatLng(7.27, -73.15),
          centroFinca: finca,
          hectareas: 12,
        ),
        isFalse,
      );
    });

    test('sin punto de finca no se restringe nada', () {
      // Es preferible un lote sin verificar a un productor que no puede
      // registrarlo porque nadie marcó la finca.
      expect(
        dentroDelPerimetro(
          punto: const LatLng(7.27, -73.15),
          centroFinca: null,
          hectareas: 12,
        ),
        isTrue,
      );
    });

    test('una finca grande admite lotes más lejos que una chica', () {
      const lejano = LatLng(6.8886, -73.41); // ~950 m al norte
      expect(
        dentroDelPerimetro(punto: lejano, centroFinca: finca, hectareas: 2),
        isFalse,
      );
      expect(
        dentroDelPerimetro(punto: lejano, centroFinca: finca, hectareas: 60),
        isTrue,
      );
    });
  });

  test('la distancia se dice en palabras del campo', () {
    expect(distanciaEnPalabras(480), '480 m');
    expect(distanciaEnPalabras(1200), '1,2 km');
    expect(distanciaEnPalabras(48000), '48 km');
  });
}
