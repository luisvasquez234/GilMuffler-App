-- Agrega el apellido del cliente como campo separado.
-- Seguro de correr más de una vez (add column if not exists).
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table clientes add column if not exists apellido text;

notify pgrst, 'reload schema';
