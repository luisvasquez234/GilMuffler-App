-- Permite agregar llamadas pendientes a mano (sin que vengan de una orden),
-- con nombre de cliente y carro/modelo/año propios.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table llamadas_ordenes alter column orden_id drop not null;
alter table llamadas_ordenes drop constraint if exists llamadas_ordenes_motivo_check;
alter table llamadas_ordenes add column if not exists cliente_id uuid references clientes(id);
alter table llamadas_ordenes add column if not exists vehiculo_marca text;
alter table llamadas_ordenes add column if not exists vehiculo_modelo text;
alter table llamadas_ordenes add column if not exists vehiculo_anio text;

notify pgrst, 'reload schema';
