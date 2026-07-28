-- Checklist rápido de inspección por orden de servicio (frenos, luces,
-- llantas, fluidos).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table ordenes_servicio add column if not exists check_frenos boolean not null default false;
alter table ordenes_servicio add column if not exists check_luces boolean not null default false;
alter table ordenes_servicio add column if not exists check_llantas boolean not null default false;
alter table ordenes_servicio add column if not exists check_fluidos boolean not null default false;

notify pgrst, 'reload schema';
