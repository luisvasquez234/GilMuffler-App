-- My Account (login individual): tabla de perfiles de empleados, ligada a
-- Supabase Auth. El endurecimiento de RLS (que las demás tablas exijan
-- sesión real) se aplica en un paso aparte, después de confirmar que el
-- login nuevo funciona — para no dejar a Luis fuera de su propia app.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists empleados (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

alter table empleados enable row level security;
drop policy if exists "empleados_autenticados" on empleados;
create policy "empleados_autenticados" on empleados
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
