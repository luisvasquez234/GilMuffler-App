-- Reportes de trabajo mandados por los mecánicos vía QR desde su celular
-- (escanean un QR por mecánico en Registro diario, inician sesión con su
-- cuenta de empleado, y mandan carro/descripción/labor/piezas/otro). Quedan
-- en un buzón aparte (revisado = false) hasta que Luis los revisa y los
-- agrega a la fila real del día en Registro diario.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists reportes_trabajo (
  id uuid primary key default gen_random_uuid(),
  mecanico_id uuid not null references mecanicos(id),
  fecha date not null,
  carro text,
  descripcion text,
  labor numeric(10,2) not null default 0,
  piezas numeric(10,2) not null default 0,
  otro numeric(10,2) not null default 0,
  revisado boolean not null default false,
  creado_en timestamptz not null default now()
);

alter table reportes_trabajo enable row level security;

drop policy if exists "acceso_compartido_reportes_trabajo" on reportes_trabajo;
create policy "acceso_compartido_reportes_trabajo" on reportes_trabajo
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
