-- Historial de precios de piezas: guarda una fila cada vez que cambia el
-- costo o el precio de venta de una pieza, para ver cuándo un proveedor subió
-- el precio.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists pieza_precio_historial (
  id uuid primary key default gen_random_uuid(),
  pieza_id uuid not null references piezas(id) on delete cascade,
  costo numeric(10,2) not null default 0,
  precio_venta numeric(10,2) not null default 0,
  proveedor text,
  fecha date not null default current_date,
  created_at timestamptz not null default now()
);

alter table pieza_precio_historial enable row level security;

drop policy if exists "acceso_compartido_pieza_precio_historial" on pieza_precio_historial;
create policy "acceso_compartido_pieza_precio_historial" on pieza_precio_historial
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
