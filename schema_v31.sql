-- Permite que un cliente anónimo (QR en el mostrador) pida que le llamen,
-- sin necesitar cuenta ni estar ya registrado como cliente.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table llamadas_ordenes add column if not exists nombre_contacto text;
alter table llamadas_ordenes add column if not exists telefono_contacto text;

drop policy if exists "llamadas_creacion_publica" on llamadas_ordenes;
create policy "llamadas_creacion_publica" on llamadas_ordenes
  for insert
  with check (
    orden_id is null
    and cliente_id is null
    and hecha = false
    and nombre_contacto is not null
    and telefono_contacto is not null
  );

notify pgrst, 'reload schema';
