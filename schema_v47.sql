-- Reservar cita en línea desde la página pública (bienvenida.html), con un
-- interruptor en el panel para mostrarlo/ocultarlo cuando quieras
-- (web_reservas_activo). Las citas hechas desde la web quedan con
-- cliente_id/vehiculo_id vacíos y sus propios datos de contacto — igual que
-- ya pasa con "llamadas_ordenes" del QR del mostrador — y aparecen en la
-- misma pestaña "Reservas" del panel para que el encargado las confirme.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table citas add column if not exists nombre_contacto text;
alter table citas add column if not exists telefono_contacto text;
alter table citas add column if not exists vehiculo_marca text;
alter table citas add column if not exists vehiculo_modelo text;
alter table citas add column if not exists vehiculo_anio text;
alter table citas add column if not exists hora_preferida text;

alter table configuracion_negocio add column if not exists web_reservas_activo boolean not null default false;

-- Cualquier persona (sin sesión) puede crear una cita pendiente de
-- confirmar desde la página pública, pero solo con sus propios datos de
-- contacto (no puede tocar cliente_id/vehiculo_id de un cliente real, ni
-- marcarla como algo distinto de "agendada").
drop policy if exists "citas_creacion_publica" on citas;
create policy "citas_creacion_publica" on citas
  for insert
  with check (
    cliente_id is null
    and vehiculo_id is null
    and estado = 'agendada'
    and fecha is not null
    and nombre_contacto is not null
    and telefono_contacto is not null
  );

notify pgrst, 'reload schema';
