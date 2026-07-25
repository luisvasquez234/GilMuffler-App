-- ============================================================
-- SCRIPT COMPLETO — corre este archivo una sola vez y ya no hace
-- falta correr ninguno de los otros (schema.sql, schema_v2.sql,
-- schema_v3.sql, etc.) Es 100% seguro de repetir las veces que
-- quieras: no borra datos, y no falla si algo ya existe.
-- Copia y pega TODO este archivo en Supabase: SQL Editor -> New query -> Run.
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- clientes ----------
create table if not exists clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  telefono text,
  email text,
  direccion text,
  vehiculo_marca text,
  vehiculo_modelo text,
  vehiculo_anio text,
  vehiculo_placa text,
  vehiculo_kilometraje text,
  notas text,
  created_at timestamptz not null default now()
);
alter table clientes add column if not exists vehiculo_kilometraje text;

-- ---------- facturas ----------
create table if not exists facturas (
  id uuid primary key default gen_random_uuid(),
  numero bigserial not null,
  cliente_id uuid not null references clientes(id) on delete restrict,
  fecha date not null default current_date,
  estado text not null default 'pendiente' check (estado in ('pendiente','pagada','cancelada')),
  subtotal numeric(10,2) not null default 0,
  impuesto numeric(10,2) not null default 0,
  total numeric(10,2) not null default 0,
  notas text,
  orden_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists factura_items (
  id uuid primary key default gen_random_uuid(),
  factura_id uuid not null references facturas(id) on delete cascade,
  descripcion text not null,
  cantidad numeric(10,2) not null default 1,
  precio_unitario numeric(10,2) not null default 0,
  subtotal numeric(10,2) not null default 0,
  orden int not null default 0
);

-- ---------- órdenes de servicio ----------
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

alter table facturas add column if not exists orden_id uuid references ordenes_servicio(id);

-- ---------- piezas (inventario) ----------
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

-- ---------- tareas ----------
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

-- ---------- gastos ----------
create table if not exists gastos (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  categoria text,
  descripcion text,
  monto numeric(10,2) not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- configuración del negocio ----------
create table if not exists configuracion_negocio (
  id integer primary key default 1,
  nombre_negocio text,
  direccion text,
  telefono text,
  email text,
  mensaje_pie text,
  logo_url text,
  texto_adicional text,
  updated_at timestamptz not null default now(),
  constraint configuracion_negocio_single_row check (id = 1)
);
alter table configuracion_negocio add column if not exists logo_url text;
alter table configuracion_negocio add column if not exists texto_adicional text;

insert into configuracion_negocio (id, nombre_negocio, mensaje_pie)
values (1, 'Gil Muffler', '¡Gracias por su preferencia!')
on conflict (id) do nothing;

-- ---------- seguridad: acceso compartido en todas las tablas ----------
alter table clientes enable row level security;
alter table facturas enable row level security;
alter table factura_items enable row level security;
alter table ordenes_servicio enable row level security;
alter table piezas enable row level security;
alter table orden_piezas enable row level security;
alter table tareas enable row level security;
alter table gastos enable row level security;
alter table configuracion_negocio enable row level security;

drop policy if exists "acceso_compartido_clientes" on clientes;
create policy "acceso_compartido_clientes" on clientes for all using (true) with check (true);

drop policy if exists "acceso_compartido_facturas" on facturas;
create policy "acceso_compartido_facturas" on facturas for all using (true) with check (true);

drop policy if exists "acceso_compartido_factura_items" on factura_items;
create policy "acceso_compartido_factura_items" on factura_items for all using (true) with check (true);

drop policy if exists "acceso_compartido_ordenes_servicio" on ordenes_servicio;
create policy "acceso_compartido_ordenes_servicio" on ordenes_servicio for all using (true) with check (true);

drop policy if exists "acceso_compartido_piezas" on piezas;
create policy "acceso_compartido_piezas" on piezas for all using (true) with check (true);

drop policy if exists "acceso_compartido_orden_piezas" on orden_piezas;
create policy "acceso_compartido_orden_piezas" on orden_piezas for all using (true) with check (true);

drop policy if exists "acceso_compartido_tareas" on tareas;
create policy "acceso_compartido_tareas" on tareas for all using (true) with check (true);

drop policy if exists "acceso_compartido_gastos" on gastos;
create policy "acceso_compartido_gastos" on gastos for all using (true) with check (true);

drop policy if exists "acceso_compartido_configuracion_negocio" on configuracion_negocio;
create policy "acceso_compartido_configuracion_negocio" on configuracion_negocio for all using (true) with check (true);

-- ---------- índices ----------
create index if not exists idx_facturas_cliente_id on facturas (cliente_id);
create index if not exists idx_factura_items_factura_id on factura_items (factura_id);
create index if not exists idx_facturas_orden_id on facturas (orden_id);
create index if not exists idx_ordenes_servicio_cliente_id on ordenes_servicio (cliente_id);
create index if not exists idx_orden_piezas_orden_id on orden_piezas (orden_id);
create index if not exists idx_orden_piezas_pieza_id on orden_piezas (pieza_id);
create index if not exists idx_tareas_cliente_id on tareas (cliente_id);
create index if not exists idx_tareas_orden_id on tareas (orden_id);
create index if not exists idx_gastos_fecha on gastos (fecha);

-- ---------- forzar que Supabase refresque su caché ----------
notify pgrst, 'reload schema';
