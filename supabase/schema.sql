-- Modelo de datos Fase 1 — espejo en Supabase/PostgreSQL de las tablas Drift
-- que corren offline en el dispositivo (lib/data/local/tables.dart).
--
-- Ejecutar en el SQL Editor de Supabase. El script es **idempotente**: se puede
-- volver a correr las veces que haga falta sin borrar datos ni fallar porque
-- algo ya exista.
--
-- Tres decisiones que no son obvias:
--
--  1. NO existen aqui sync_status ni sync_error: son estado LOCAL ("¿ya subi
--     esto?"). Si viajaran, una descarga pisaria el estado del dispositivo.
--
--  2. updated_at lo escribe SIEMPRE el servidor (trigger de abajo), ignorando
--     lo que mande el cliente: es el unico reloj comparable entre dispositivos.
--     Un telefono con la hora mal no puede envenenar la sincronizacion.
--
--  3. Todas las fechas son timestamptz, nunca date. Con date, un valor local
--     con hora volveria a medianoche al bajar y la fila se veria "cambiada" en
--     cada ciclo: un bucle de escrituras infinito.

-- ---------------------------------------------------------------- tipos ----

do $$ begin
  create type tipo_actividad as enum (
    'poda', 'fertilizacion', 'controlFitosanitario', 'riego', 'otro'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type estado_fenologico as enum (
    'vegetativo', 'floracion', 'cuajado', 'fructificacion', 'maduracion',
    'cosecha'
  );
exception when duplicate_object then null;
end $$;

-- --------------------------------------------------------------- tablas ----
--
-- Columnas comunes a todas (ver el mixin SyncColumns en Dart):
--   id uuid primary key      -- generado en el dispositivo, no serial
--   created_at, updated_at   -- updated_at lo sella el trigger
--   deleted_at               -- borrado suave: nunca se borra fisico

create table if not exists asociaciones (
  id uuid primary key,
  nombre text not null,
  municipio text not null,
  departamento text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Catálogo inicial (RF-23): mismos ids que `asociaciones_semilla.dart`, para
-- que cada instalación y Supabase partan del mismo catálogo.
insert into asociaciones (id, nombre, municipio, departamento) values
  ('a0000001-0000-4000-8000-000000000001', 'FEDECACAO', '', ''),
  ('a0000001-0000-4000-8000-000000000002', 'FEPCACAO', '', ''),
  ('a0000001-0000-4000-8000-000000000003', 'ASOMUSTIC', '', ''),
  ('a0000001-0000-4000-8000-000000000004', 'APROCAVILLA', '', ''),
  ('a0000001-0000-4000-8000-000000000005', 'AMUCAFUE', '', '')
on conflict (id) do nothing;

-- El id es el UUID que genero el dispositivo y no cambia nunca; usuario_id es
-- el dueño segun Supabase Auth (sesion anonima). Separarlos permite crear el
-- perfil sin conexion, antes de que exista sesion.
create table if not exists productores (
  id uuid primary key,
  usuario_id uuid not null references auth.users (id) on delete cascade,
  nombre_completo text not null,
  telefono text,
  email text,
  asociacion_id uuid references asociaciones (id),
  tipo_documento text,
  numero_documento text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Aditivo: instalaciones ya desplegadas de este script no tenían estas dos
-- columnas (documento de identidad del productor, RF-01).
alter table productores add column if not exists tipo_documento text;
alter table productores add column if not exists numero_documento text;

create table if not exists fincas (
  id uuid primary key,
  productor_id uuid not null references productores (id) on delete cascade,
  nombre text not null,
  latitud double precision,
  longitud double precision,
  municipio text not null,
  departamento text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists lotes (
  id uuid primary key,
  finca_id uuid not null references fincas (id) on delete cascade,
  nombre text not null,
  area_sembrada_ha double precision not null,
  variedad_cacao text not null,
  fecha_siembra timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists actividades_agricolas (
  id uuid primary key,
  lote_id uuid not null references lotes (id) on delete cascade,
  tipo_actividad tipo_actividad not null,
  fecha timestamptz not null,
  observaciones text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists cosechas (
  id uuid primary key,
  lote_id uuid not null references lotes (id) on delete cascade,
  fecha timestamptz not null,
  cantidad_kg double precision not null,
  observaciones text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists diagnosticos (
  id uuid primary key,
  lote_id uuid not null references lotes (id) on delete cascade,
  fecha timestamptz not null,
  foto_path text,
  estado_fenologico estado_fenologico not null,
  notas text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ------------------------------------------------------- reloj del server --

create or replace function sellar_updated_at() returns trigger as $$
begin
  new.updated_at := now();
  return new;
end;
$$ language plpgsql;

do $$
declare t text;
begin
  foreach t in array array[
    'asociaciones', 'productores', 'fincas', 'lotes',
    'actividades_agricolas', 'cosechas', 'diagnosticos'
  ] loop
    execute format('drop trigger if exists sellar_%1$s on %1$s', t);
    execute format(
      'create trigger sellar_%1$s before insert or update on %1$s '
      'for each row execute function sellar_updated_at()', t);
  end loop;
end $$;

-- -------------------------------------------------------------- indices ----
-- La descarga incremental ordena por (updated_at, id).

create index if not exists productores_sync_idx on productores (updated_at, id);
create index if not exists fincas_sync_idx on fincas (updated_at, id);
create index if not exists lotes_sync_idx on lotes (updated_at, id);
create index if not exists actividades_sync_idx
  on actividades_agricolas (updated_at, id);
create index if not exists cosechas_sync_idx on cosechas (updated_at, id);
create index if not exists diagnosticos_sync_idx
  on diagnosticos (updated_at, id);

create index if not exists fincas_productor_idx on fincas (productor_id);
create index if not exists lotes_finca_idx on lotes (finca_id);
create index if not exists actividades_lote_idx
  on actividades_agricolas (lote_id);
create index if not exists cosechas_lote_idx on cosechas (lote_id);
create index if not exists diagnosticos_lote_idx on diagnosticos (lote_id);

-- --------------------------------------------------- seguridad por fila ----
-- Cada usuario (incluida la sesion anonima) solo ve y escribe lo suyo.

alter table asociaciones enable row level security;
alter table productores enable row level security;
alter table fincas enable row level security;
alter table lotes enable row level security;
alter table actividades_agricolas enable row level security;
alter table cosechas enable row level security;
alter table diagnosticos enable row level security;

drop policy if exists "productor ve lo suyo" on productores;
create policy "productor ve lo suyo" on productores
  for all using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

drop policy if exists "productor ve sus fincas" on fincas;
create policy "productor ve sus fincas" on fincas
  for all using (
    exists (
      select 1 from productores p
      where p.id = fincas.productor_id and p.usuario_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from productores p
      where p.id = fincas.productor_id and p.usuario_id = auth.uid()
    )
  );

drop policy if exists "productor ve sus lotes" on lotes;
create policy "productor ve sus lotes" on lotes
  for all using (
    exists (
      select 1 from fincas f join productores p on p.id = f.productor_id
      where f.id = lotes.finca_id and p.usuario_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from fincas f join productores p on p.id = f.productor_id
      where f.id = lotes.finca_id and p.usuario_id = auth.uid()
    )
  );

-- Las tres tablas hoja comparten la misma regla: se llega por lote -> finca.
do $$
declare t text;
begin
  foreach t in array array['actividades_agricolas', 'cosechas', 'diagnosticos']
  loop
    execute format(
      'drop policy if exists "productor ve sus registros" on %1$s', t);
    execute format($f$
      create policy "productor ve sus registros" on %1$s
        for all using (
          exists (
            select 1 from lotes l
              join fincas f on f.id = l.finca_id
              join productores p on p.id = f.productor_id
            where l.id = %1$s.lote_id and p.usuario_id = auth.uid()
          )
        ) with check (
          exists (
            select 1 from lotes l
              join fincas f on f.id = l.finca_id
              join productores p on p.id = f.productor_id
            where l.id = %1$s.lote_id and p.usuario_id = auth.uid()
          )
        )$f$, t);
  end loop;
end $$;

-- Las asociaciones son catalogo publico: cualquiera autenticado las consulta.
drop policy if exists "asociaciones visibles" on asociaciones;
create policy "asociaciones visibles" on asociaciones
  for select using (auth.role() = 'authenticated');

-- Un productor puede agregar su asociación si no está en el catálogo ("Otra,
-- especificar" en la app), pero no editar ni borrar las que ya existen.
drop policy if exists "autenticados crean asociaciones" on asociaciones;
create policy "autenticados crean asociaciones" on asociaciones
  for insert to authenticated with check (auth.role() = 'authenticated');
