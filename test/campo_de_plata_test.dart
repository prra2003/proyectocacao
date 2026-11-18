import 'package:cacao_app/ui/formato.dart';
import 'package:cacao_app/ui/widgets/comunes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un costo de seis cifras sin puntos es muy fácil de equivocar: `150000` y
/// `1500000` se ven casi igual, y ese error no se nota hasta que el costo por
/// kilo sale diez veces más caro. Por eso el campo pone los puntos solo.
void main() {
  const filtro = FiltroPesos();

  /// Simula escribir [texto] de un tirón en un campo vacío.
  TextEditingValue escribir(String texto, {TextEditingValue? sobre}) {
    final viejo = sobre ?? const TextEditingValue();
    return filtro.formatEditUpdate(
      viejo,
      TextEditingValue(
        text: texto,
        selection: TextSelection.collapsed(offset: texto.length),
      ),
    );
  }

  test('los puntos de mil se van poniendo solos', () {
    expect(escribir('1').text, '1');
    expect(escribir('150').text, '150');
    expect(escribir('1500').text, '1.500');
    expect(escribir('150000').text, '150.000');
    expect(escribir('1500000').text, '1.500.000');
  });

  test('se escriben dígitos sueltos y el campo los reacomoda', () {
    // Lo que de verdad pasa al teclear: el campo ya tiene "150.000" y se
    // agrega un 0 al final.
    final antes = escribir('150000');
    final despues = escribir('${antes.text}0', sobre: antes);

    expect(despues.text, '1.500.000');
    expect(
      despues.selection.baseOffset,
      despues.text.length,
      reason: 'El cursor sigue al final, donde está escribiendo.',
    );
  });

  test('corrigiendo por la mitad, el cursor no se va al final', () {
    // "1.500.000" y borra el 5: quedan 7 dígitos y el cursor debe quedar
    // justo después del primero, no al final del campo.
    const antes = TextEditingValue(
      text: '1.500.000',
      selection: TextSelection.collapsed(offset: 3),
    );
    final despues = filtro.formatEditUpdate(
      antes,
      const TextEditingValue(
        text: '1.00.000',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );

    expect(despues.text, '100.000');
    expect(
      despues.selection.baseOffset,
      1,
      reason: 'Queda después del 1, que es donde estaba. Si saltara al final, '
          'corregir una cifra sería imposible.',
    );
  });

  test('lo que no es número no entra', () {
    expect(escribir('abc').text, '');
    expect(escribir('1a5b0').text, '150');
    expect(
      escribir('1,50').text,
      '150',
      reason: 'No se admiten centavos: nadie anota un jornal con decimales, '
          'y la coma solo serviría para confundirla con los puntos de mil.',
    );
  });

  test('un campo vacío se queda vacío, no en cero', () {
    expect(escribir('').text, '');
    expect(aPesos(''), isNull);
  });

  test('lo escrito se vuelve a leer como el mismo número', () {
    expect(aPesos('150.000'), 150000);
    expect(aPesos('1.500.000'), 1500000);
    expect(
      aPesos('1.500'),
      1500,
      reason: 'Mil quinientos pesos, no uno con cinco: aquí el punto separa '
          'miles, no decimales.',
    );
  });

  test('los puntos que se escriben son los mismos que se muestran', () {
    expect(conPuntosDeMil('150000'), '150.000');
    expect(pesos(150000), r'$150.000');
    expect(escribir('150000').text, '150.000');
  });
}
