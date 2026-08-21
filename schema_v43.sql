-- Agrega el estado "no_show" a las citas, para poder marcar cuando un
-- cliente reservó y no llegó (distinto de "cancelada", que es cuando avisa
-- con tiempo). Esto permite medir cuántas citas se pierden por no-shows.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table citas drop constraint if exists citas_estado_check;
alter table citas add constraint citas_estado_check
  check (estado in ('agendada','confirmada','completada','cancelada','no_show'));

notify pgrst, 'reload schema';
