-- Esquema para el panel de Gil Muffler.
-- Copia y pega todo este archivo en Supabase: proyecto -> SQL Editor -> New query -> Run.

create extension if not exists "pgcrypto";

create table clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  telefono text,
  email text,
  direccion text,
  vehiculo_marca text,
  vehiculo_modelo text,
  vehiculo_anio text,
  vehiculo_placa text,
  notas text,
  created_at timestamptz not null default now()
);

create table facturas (
  id uuid primary key default gen_random_uuid(),
  numero bigserial not null,
  cliente_id uuid not null references clientes(id) on delete restrict,
  fecha date not null default current_date,
  estado text not null default 'pendiente' check (estado in ('pendiente','pagada','cancelada')),
  subtotal numeric(10,2) not null default 0,
  impuesto numeric(10,2) not null default 0,
  total numeric(10,2) not null default 0,
  notas text,
  created_at timestamptz not null default now()
);

create table factura_items (
  id uuid primary key default gen_random_uuid(),
  factura_id uuid not null references facturas(id) on delete cascade,
  descripcion text not null,
  cantidad numeric(10,2) not null default 1,
  precio_unitario numeric(10,2) not null default 0,
  subtotal numeric(10,2) not null default 0,
  orden int not null default 0
);

-- Acceso compartido temporal: todos los empleados usan la misma clave de la app,
-- así que por ahora dejamos las tablas abiertas a la llave "anon" de Supabase.
-- Cuando se agreguen usuarios individuales, estas políticas deben cambiarse
-- para exigir autenticación real (auth.uid()) en vez de "using (true)".

alter table clientes enable row level security;
alter table facturas enable row level security;
alter table factura_items enable row level security;

create policy "acceso_compartido_clientes" on clientes
  for all using (true) with check (true);

create policy "acceso_compartido_facturas" on facturas
  for all using (true) with check (true);

create policy "acceso_compartido_factura_items" on factura_items
  for all using (true) with check (true);

create index on facturas (cliente_id);
create index on factura_items (factura_id);
