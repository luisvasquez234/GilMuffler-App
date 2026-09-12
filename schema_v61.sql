-- Recordatorio automático de mantenimiento: guarda cuándo se le mandó por
-- última vez el email de "ya te toca servicio" a un vehículo, para no
-- mandarlo repetido todos los días mientras siga vencido. Se limpia solo la
-- próxima vez que el vehículo tenga una visita más reciente que este valor
-- (ver scripts/recordatorio-mantenimiento.mjs).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table vehiculos add column if not exists recordatorio_mantenimiento_enviado_en date;

notify pgrst, 'reload schema';
