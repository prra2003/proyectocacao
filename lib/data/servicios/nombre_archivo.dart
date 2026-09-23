/// Un nombre de archivo seguro a partir de un texto libre (el nombre de una
/// finca, de un lote...): sin tildes, espacios ni símbolos que compliquen
/// guardarlo o compartirlo.
String nombreDeArchivo(String texto) => texto
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[áàä]'), 'a')
    .replaceAll(RegExp(r'[éèë]'), 'e')
    .replaceAll(RegExp(r'[íìï]'), 'i')
    .replaceAll(RegExp(r'[óòö]'), 'o')
    .replaceAll(RegExp(r'[úùü]'), 'u')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_');