-- Permite marcar manualmente si una factura tiene garantía o no, en vez de
-- que salga siempre según los días de garantía globales de Configuración.
-- Por defecto queda en true para no cambiar el comportamiento de facturas
-- ya existentes.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table facturas add column if not exists garantia boolean not null default true;

notify pgrst, 'reload schema';
