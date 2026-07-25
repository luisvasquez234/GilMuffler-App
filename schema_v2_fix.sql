-- Version segura de reintentar: usa "if not exists" en todo, así que no importa
-- qué parte de schema_v2.sql ya se haya ejecutado antes — esto no falla si algo
-- ya existe, y completa lo que falte (por ejemplo la columna orden_id en facturas).
-- Copia y pega TODO esto en Supabase: SQL Editor -> New query -> Run.

create table if not exists ordenes_servicio (
  id uuid primary key default gen_random_uuid(),
  numero bigserial not null,
  cliente_id uuid not null references clientes(id) on delete restrict,
  etapa text not null default 'diagnostico'
    check (etapa in ('diagnostico','presupuesto','aprobado','en_reparacion','completado','facturado','cancelado')),
  vehiculo_marca text,
  vehiculo_modelo text,
  vehiculo_anio text,
  vehiculo_placa text,
  kilometraje text,
  diagnostico text,
  trabajo_recomendado text,
  fecha_recepcion date not null default current_date,
  fecha_estimada date,
  notas text,
  created_at timestamptz not null default now()
);

create table if not exists piezas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  sku text,
  categoria text,
  costo numeric(10,2) not null default 0,
  precio_venta numeric(10,2) not null default 0,
  stock numeric(10,2) not null default 0,
  stock_minimo numeric(10,2) not null default 0,
  proveedor text,
  notas text,
  created_at timestamptz not null default now()
);

create table if not exists orden_piezas (
  id uuid primary key default gen_random_uuid(),
  orden_id uuid not null references ordenes_servicio(id) on delete cascade,
  pieza_id uuid not null references piezas(id) on delete restrict,
  cantidad numeric(10,2) not null default 1,
  precio_unitario numeric(10,2) not null default 0
);

create table if not exists tareas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid references clientes(id) on delete cascade,
  orden_id uuid references ordenes_servicio(id) on delete cascade,
  titulo text not null,
  descripcion text,
  fecha_vencimiento date,
  completada boolean not null default false,
  created_at timestamptz not null default now()
);

alter table clientes add column if not exists vehiculo_kilometraje text;
alter table facturas add column if not exists orden_id uuid references ordenes_servicio(id);

alter table ordenes_servicio enable row level security;
alter table piezas enable row level security;
alter table orden_piezas enable row level security;
alter table tareas enable row level security;

drop policy if exists "acceso_compartido_ordenes_servicio" on ordenes_servicio;
create policy "acceso_compartido_ordenes_servicio" on ordenes_servicio
  for all using (true) with check (true);

drop policy if exists "acceso_compartido_piezas" on piezas;
create policy "acceso_compartido_piezas" on piezas
  for all using (true) with check (true);

drop policy if exists "acceso_compartido_orden_piezas" on orden_piezas;
create policy "acceso_compartido_orden_piezas" on orden_piezas
  for all using (true) with check (true);

drop policy if exists "acceso_compartido_tareas" on tareas;
create policy "acceso_compartido_tareas" on tareas
  for all using (true) with check (true);

create index if not exists idx_ordenes_servicio_cliente_id on ordenes_servicio (cliente_id);
create index if not exists idx_orden_piezas_orden_id on orden_piezas (orden_id);
create index if not exists idx_orden_piezas_pieza_id on orden_piezas (pieza_id);
create index if not exists idx_tareas_cliente_id on tareas (cliente_id);
create index if not exists idx_tareas_orden_id on tareas (orden_id);
create index if not exists idx_facturas_orden_id on facturas (orden_id);
