-- Pagos parciales (abonos) de facturas: una factura ya no tiene que ser
-- "todo o nada" — se le pueden ir registrando abonos hasta completar el
-- total. Cuando la suma de abonos llega al total, la factura pasa sola a
-- "pagada"; mientras esté a medias, queda en un nuevo estado "parcial".
-- Mismo patrón de lectura pública que ya usa "facturas" (para que
-- ver-factura.html pueda mostrar el saldo sin necesitar sesión).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

-- Busca y elimina el check constraint existente de "estado" sin depender de
-- adivinar su nombre exacto (por si no fuera el autogenerado de Postgres),
-- y agrega el nuevo que además permite 'parcial'.
do $$
declare
  c record;
begin
  for c in
    select con.conname
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    where rel.relname = 'facturas' and con.contype = 'c' and pg_get_constraintdef(con.oid) ilike '%estado%'
  loop
    execute format('alter table facturas drop constraint %I', c.conname);
  end loop;
end $$;

alter table facturas add constraint facturas_estado_check
  check (estado in ('pendiente', 'pagada', 'cancelada', 'parcial'));

create table if not exists factura_pagos (
  id uuid primary key default gen_random_uuid(),
  factura_id uuid not null references facturas(id) on delete cascade,
  monto numeric(10,2) not null check (monto > 0),
  fecha date not null default current_date,
  metodo_pago text check (metodo_pago in ('efectivo', 'tarjeta', 'cheque')),
  created_at timestamptz not null default now()
);

alter table factura_pagos enable row level security;

drop policy if exists "factura_pagos_lectura_publica" on factura_pagos;
create policy "factura_pagos_lectura_publica" on factura_pagos
  for select using (true);
drop policy if exists "factura_pagos_escritura_autenticada" on factura_pagos;
create policy "factura_pagos_escritura_autenticada" on factura_pagos
  for insert with check (auth.role() = 'authenticated');
drop policy if exists "factura_pagos_actualizacion_autenticada" on factura_pagos;
create policy "factura_pagos_actualizacion_autenticada" on factura_pagos
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
drop policy if exists "factura_pagos_borrado_autenticado" on factura_pagos;
create policy "factura_pagos_borrado_autenticado" on factura_pagos
  for delete using (auth.role() = 'authenticated');

create index if not exists idx_factura_pagos_factura_id on factura_pagos (factura_id);

notify pgrst, 'reload schema';
