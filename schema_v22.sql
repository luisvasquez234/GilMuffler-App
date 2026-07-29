-- Registro diario de trabajo por mecánico (digitaliza la hoja de papel:
-- carro, trabajo, labor, piezas, otro trabajo, dinero de salida, por mecánico
-- y por día, con resumen de tarjeta/efectivo/cheque).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists mecanicos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists registro_diario (
  id uuid primary key default gen_random_uuid(),
  fecha date not null unique,
  credit_card_total numeric(10,2) not null default 0,
  cash_total numeric(10,2) not null default 0,
  check_total numeric(10,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists registro_diario_items (
  id uuid primary key default gen_random_uuid(),
  registro_id uuid not null references registro_diario(id) on delete cascade,
  mecanico_id uuid not null references mecanicos(id),
  carro text,
  descripcion text,
  labor numeric(10,2) not null default 0,
  piezas numeric(10,2) not null default 0,
  otro numeric(10,2) not null default 0,
  dinero_salida numeric(10,2) not null default 0,
  orden integer not null default 0,
  created_at timestamptz not null default now()
);

insert into mecanicos (nombre)
select nombre from (values ('Ysidro'), ('Quide'), ('Joan'), ('Victor')) as v(nombre)
where not exists (select 1 from mecanicos);

alter table mecanicos enable row level security;
alter table registro_diario enable row level security;
alter table registro_diario_items enable row level security;

drop policy if exists "acceso_compartido_mecanicos" on mecanicos;
create policy "acceso_compartido_mecanicos" on mecanicos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
drop policy if exists "acceso_compartido_registro_diario" on registro_diario;
create policy "acceso_compartido_registro_diario" on registro_diario
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
drop policy if exists "acceso_compartido_registro_diario_items" on registro_diario_items;
create policy "acceso_compartido_registro_diario_items" on registro_diario_items
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
