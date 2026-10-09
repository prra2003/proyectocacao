/// En el celular la base local **es** el original: si no abre, borrarla sería
/// perder el trabajo del productor. Así que aquí no se recupera nada; el
/// error sube y se ve.
Future<bool> rehacerBaseLocal() async => false;
