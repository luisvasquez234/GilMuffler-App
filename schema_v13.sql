-- Bookings (reservas/citas): agenda de citas próximas del taller.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists citas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid references clientes(id) on delete set null,
  vehiculo_id uuid references vehiculos(id) on delete set null,
  fecha date not null,
  hora time,
  servicio text,
  notas text,
  estado text not null default 'agendada'
    check (estado in ('agendada','confirmada','completada','cancelada')),
  created_at timestamptz not null default now()
);

alter table citas enable row level security;
drop policy if exists "acceso_compartido_citas" on citas;
create policy "acceso_compartido_citas" on citas for all using (true) with check (true);

create index if not exists idx_citas_fecha on citas (fecha);
create index if not exists idx_citas_cliente_id on citas (cliente_id);

notify pgrst, 'reload schema';
