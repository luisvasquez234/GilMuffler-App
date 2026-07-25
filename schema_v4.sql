-- Agrega el módulo de Gastos, para poder calcular ganancias y pérdidas.
-- Es seguro de correr sin importar qué otras migraciones ya se hayan aplicado.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists gastos (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  categoria text,
  descripcion text,
  monto numeric(10,2) not null default 0,
  created_at timestamptz not null default now()
);

alter table gastos enable row level security;

drop policy if exists "acceso_compartido_gastos" on gastos;
create policy "acceso_compartido_gastos" on gastos
  for all using (true) with check (true);

create index if not exists idx_gastos_fecha on gastos (fecha);
