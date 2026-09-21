/// Catálogo inicial de asociaciones (RF-23), igual en toda instalación y en
/// Supabase (mismos ids fijos: ver `supabase/schema.sql`), para que el
/// productor tenga opciones desde el primer arranque, sin señal.
const asociacionesSemilla = [
  (id: 'a0000001-0000-4000-8000-000000000001', nombre: 'FEDECACAO'),
  (id: 'a0000001-0000-4000-8000-000000000002', nombre: 'FEPCACAO'),
  (id: 'a0000001-0000-4000-8000-000000000003', nombre: 'ASOMUSTIC'),
  (id: 'a0000001-0000-4000-8000-000000000004', nombre: 'APROCAVILLA'),
  (id: 'a0000001-0000-4000-8000-000000000005', nombre: 'AMUCAFUE'),
];
