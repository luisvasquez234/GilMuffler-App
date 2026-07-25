-- Agrega el formato de fecha configurable (MM/DD/YYYY o DD/MM/YYYY).
-- Seguro de correr sin importar qué otras migraciones ya se hayan aplicado.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists formato_fecha text not null default 'MM/DD/YYYY';

notify pgrst, 'reload schema';
