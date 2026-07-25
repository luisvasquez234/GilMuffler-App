-- Agrega el millaje del vehículo a Clientes.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table clientes add column if not exists vehiculo_kilometraje text;

notify pgrst, 'reload schema';
