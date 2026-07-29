-- Etiquetas de cliente (ej. "VIP, flotilla, moroso"), guardadas como texto
-- separado por coma.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table clientes add column if not exists etiquetas text;

notify pgrst, 'reload schema';
