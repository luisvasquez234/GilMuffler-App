-- Reportes de trabajo "aceptados sin mostrar": permite marcar un reporte de
-- un trabajador como aceptado (cuenta en el total del día) sin que aparezca
-- como fila visible en la tabla del mecánico. La columna "oculto" distingue
-- esos reportes de los que sí se agregaron como fila normal.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table reportes_trabajo add column if not exists oculto boolean not null default false;

notify pgrst, 'reload schema';
