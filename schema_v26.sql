-- Lista de "por llamar": clientes a los que hay que avisar por teléfono
-- (cuando dejan el carro, cuando hay que avisar el presupuesto, y cuando
-- ya está listo). Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists llamadas_ordenes (
  id uuid primary key default gen_random_uuid(),
  orden_id uuid not null references ordenes_servicio(id) on delete cascade,
  motivo text not null check (motivo in ('recibido','presupuesto','listo')),
  hecha boolean not null default false,
  notas text,
  fecha_hecha timestamptz,
  created_at timestamptz not null default now(),
  unique(orden_id, motivo)
);

alter table llamadas_ordenes enable row level security;

drop policy if exists "acceso_compartido_llamadas_ordenes" on llamadas_ordenes;
create policy "acceso_compartido_llamadas_ordenes" on llamadas_ordenes
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
