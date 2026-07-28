-- Historial completo de kilometraje: cada vez que se actualiza el
-- kilometraje de un vehículo (desde su ficha o desde una orden), se guarda
-- una lectura con fecha, en vez de solo pisar el valor anterior.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists kilometraje_historial (
  id uuid primary key default gen_random_uuid(),
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  kilometraje text not null,
  fecha date not null default current_date,
  created_at timestamptz not null default now()
);

alter table kilometraje_historial enable row level security;
drop policy if exists "acceso_compartido_kilometraje_historial" on kilometraje_historial;
create policy "acceso_compartido_kilometraje_historial" on kilometraje_historial
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create index if not exists idx_kilometraje_historial_vehiculo on kilometraje_historial (vehiculo_id);

notify pgrst, 'reload schema';
