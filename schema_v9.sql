-- Varios vehículos por cliente + historial de kilometraje.
-- Crea la tabla vehiculos, migra los datos que ya estaban guardados directo
-- en clientes (sin borrarlos de ahí, por seguridad), y vincula las órdenes
-- de servicio a un vehículo específico.
-- Seguro de correr sin importar qué otras migraciones ya se hayan aplicado,
-- y seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists vehiculos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references clientes(id) on delete cascade,
  marca text,
  modelo text,
  anio text,
  placa text,
  kilometraje text,
  notas text,
  created_at timestamptz not null default now()
);

alter table vehiculos enable row level security;
drop policy if exists "acceso_compartido_vehiculos" on vehiculos;
create policy "acceso_compartido_vehiculos" on vehiculos for all using (true) with check (true);

create index if not exists idx_vehiculos_cliente_id on vehiculos (cliente_id);

-- Migra el vehículo único que ya tenía cada cliente hacia la tabla nueva.
-- El "not exists" evita duplicar si este script se corre más de una vez.
insert into vehiculos (cliente_id, marca, modelo, anio, placa, kilometraje)
select c.id, c.vehiculo_marca, c.vehiculo_modelo, c.vehiculo_anio, c.vehiculo_placa, c.vehiculo_kilometraje
from clientes c
where (
    coalesce(c.vehiculo_marca, '') <> '' or
    coalesce(c.vehiculo_modelo, '') <> '' or
    coalesce(c.vehiculo_anio, '') <> '' or
    coalesce(c.vehiculo_placa, '') <> '' or
    coalesce(c.vehiculo_kilometraje, '') <> ''
  )
  and not exists (select 1 from vehiculos v where v.cliente_id = c.id);

-- Vincula cada orden de servicio a un vehículo.
alter table ordenes_servicio add column if not exists vehiculo_id uuid references vehiculos(id);
create index if not exists idx_ordenes_servicio_vehiculo_id on ordenes_servicio (vehiculo_id);

-- Backfill: enlaza órdenes ya existentes buscando un vehículo del mismo
-- cliente cuya placa coincida con la que ya tenía guardada la orden.
update ordenes_servicio o
set vehiculo_id = v.id
from vehiculos v
where o.vehiculo_id is null
  and v.cliente_id = o.cliente_id
  and coalesce(o.vehiculo_placa, '') <> ''
  and v.placa = o.vehiculo_placa;

notify pgrst, 'reload schema';
