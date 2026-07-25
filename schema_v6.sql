-- Amplía la configuración del negocio: logo por URL y texto adicional
-- (términos, garantía, o lo que quieras agregar) para la factura impresa.
-- Seguro de correr sin importar qué otras migraciones ya se hayan aplicado.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists logo_url text;
alter table configuracion_negocio add column if not exists texto_adicional text;

notify pgrst, 'reload schema';
