-- Permite guardar más de un teléfono por cliente (ej. celular y casa/trabajo),
-- para usarlos al hacer seguimiento de llamadas pendientes.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists cliente_telefonos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references clientes(id) on delete cascade,
  telefono text not null,
  etiqueta text,
  created_at timestamptz not null default now()
);

alter table cliente_telefonos enable row level security;
drop policy if exists "acceso_compartido_cliente_telefonos" on cliente_telefonos;
create policy "acceso_compartido_cliente_telefonos" on cliente_telefonos for all using (true) with check (true);

notify pgrst, 'reload schema';
