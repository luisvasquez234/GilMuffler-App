-- Inventario: ubicación física de cada pieza + historial de movimientos de
-- stock (para saber cuándo entró/salió cada pieza y sugerir reórdenes según
-- el consumo real, y detectar piezas que no se han usado en meses).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table piezas add column if not exists ubicacion text;

create table if not exists pieza_stock_historial (
  id uuid primary key default gen_random_uuid(),
  pieza_id uuid not null references piezas(id) on delete cascade,
  cambio numeric not null,
  stock_resultante numeric not null,
  motivo text not null default 'manual',
  creado_en timestamptz not null default now()
);

alter table pieza_stock_historial enable row level security;

drop policy if exists acceso_compartido_pieza_stock_historial on pieza_stock_historial;
create policy acceso_compartido_pieza_stock_historial on pieza_stock_historial
  for all using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());

notify pgrst, 'reload schema';
