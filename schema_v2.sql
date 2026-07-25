-- Ampliación del panel de Gil Muffler: Órdenes de servicio, Inventario y Tareas.
-- Esto NO borra ni modifica los datos que ya tienes en clientes/facturas.
-- Copia y pega todo este archivo en Supabase: proyecto -> SQL Editor -> New query -> Run.

create table ordenes_servicio (
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

create table piezas (
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

create table orden_piezas (
  id uuid primary key default gen_random_uuid(),
  orden_id uuid not null references ordenes_servicio(id) on delete cascade,
  pieza_id uuid not null references piezas(id) on delete restrict,
  cantidad numeric(10,2) not null default 1,
  precio_unitario numeric(10,2) not null default 0
);

create table tareas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid references clientes(id) on delete cascade,
  orden_id uuid references ordenes_servicio(id) on delete cascade,
  titulo text not null,
  descripcion text,
  fecha_vencimiento date,
  completada boolean not null default false,
  created_at timestamptz not null default now()
);

alter table facturas add column if not exists orden_id uuid references ordenes_servicio(id);

-- Mismo acceso compartido temporal que las tablas originales (ver nota en schema.sql).

alter table ordenes_servicio enable row level security;
alter table piezas enable row level security;
alter table orden_piezas enable row level security;
alter table tareas enable row level security;

create policy "acceso_compartido_ordenes_servicio" on ordenes_servicio
  for all using (true) with check (true);

create policy "acceso_compartido_piezas" on piezas
  for all using (true) with check (true);

create policy "acceso_compartido_orden_piezas" on orden_piezas
  for all using (true) with check (true);

create policy "acceso_compartido_tareas" on tareas
  for all using (true) with check (true);

create index on ordenes_servicio (cliente_id);
create index on orden_piezas (orden_id);
create index on orden_piezas (pieza_id);
create index on tareas (cliente_id);
create index on tareas (orden_id);
create index on facturas (orden_id);
