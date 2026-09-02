/// Estado de sincronización de cada registro con Supabase.
enum SyncStatus { pending, synced, error }

/// Tipos de labor cultural que el productor registra en un lote.
enum TipoActividad { poda, fertilizacion, controlFitosanitario, riego, otro }

/// Estado fenológico del cultivo al momento del diagnóstico.
enum EstadoFenologico {
  vegetativo,
  floracion,
  cuajado,
  fructificacion,
  maduracion,
  cosecha,
}
