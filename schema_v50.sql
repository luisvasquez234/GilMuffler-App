-- Deja que Luis cambie el color principal y el color del menú lateral
-- del panel él mismo, desde Configuración (no afecta el color de las
-- facturas impresas, eso es un campo aparte que ya existía).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists panel_color_acento text;
alter table configuracion_negocio add column if not exists panel_color_menu text;

notify pgrst, 'reload schema';
