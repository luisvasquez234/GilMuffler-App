-- Recordatorios de servicio por vehículo: activar/desactivar, cada cuántos
-- meses, y la última/próxima fecha en que hay que avisarle al cliente. No
-- manda nada automático todavía — solo guarda la configuración para que el
-- panel muestre una lista de "recordatorios pendientes hoy" y Luis decida
-- cómo avisar (llamada, WhatsApp, etc.).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table vehiculos add column if not exists recordatorio_activo boolean not null default false;
alter table vehiculos add column if not exists recordatorio_frecuencia_meses integer not null default 3;
alter table vehiculos add column if not exists recordatorio_ultima_fecha date;
alter table vehiculos add column if not exists recordatorio_proxima_fecha date;

notify pgrst, 'reload schema';
