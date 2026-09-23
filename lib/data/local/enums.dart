/// Estado de sincronización de cada registro con el servidor.
enum SyncStatus { pending, synced, error }

/// Tipo de documento de identidad del productor.
enum TipoDocumento {
  cedulaCiudadania,
  cedulaExtranjeria,
  tarjetaIdentidad,
  nit,
  pasaporte,
  otro,
}

/// Tipos de labor cultural que el productor registra en un lote.
enum TipoActividad {
  /// El punto de partida del lote. Va en la misma tabla que las demás labores
  /// porque comparte fecha, responsable, costo y foto; lo suyo (árboles
  /// sembrados, marco de plantación) son columnas que solo ella llena.
  siembra,
  poda,
  fertilizacion,
  controlFitosanitario,
  riego,
  otro,
}

/// Estado fenológico del cultivo al momento del diagnóstico.
enum EstadoFenologico {
  vegetativo,
  floracion,
  cuajado,
  fructificacion,
  maduracion,
  cosecha,
}
