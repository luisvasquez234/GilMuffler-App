-- Fila de espera por orden de llegada: el cliente escanea un QR en el
-- mostrador, escribe su nombre y le sale un número de turno. El número lo
-- asigna sola la base de datos (siguiente número del día), no el navegador
-- del cliente, para que dos personas no puedan sacar el mismo número aunque
-- escaneen al mismo tiempo.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists turnos (
  id uuid primary key default gen_random_uuid(),
  numero int not null,
  fecha date not null default current_date,
  nombre text not null,
  estado text not null default 'esperando' check (estado in ('esperando', 'atendido')),
  created_at timestamptz not null default now()
);

create unique index if not exists turnos_fecha_numero_idx on turnos (fecha, numero);

-- Asigna el número dentro de la misma transacción del insert, usando un
-- candado (advisory lock) por día para que dos turnos pedidos al mismo
-- tiempo nunca puedan quedar con el mismo número.
create or replace function asignar_numero_turno()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform pg_advisory_xact_lock(hashtext('turno_' || current_date::text));
  new.fecha := current_date;
  new.estado := 'esperando';
  new.numero := coalesce((select max(numero) from turnos where fecha = current_date), 0) + 1;
  return new;
end;
$$;

drop trigger if exists trg_asignar_numero_turno on turnos;
create trigger trg_asignar_numero_turno
  before insert on turnos
  for each row execute function asignar_numero_turno();

alter table turnos enable row level security;

-- Cualquier empleado con sesión (encargado o mecánico) puede ver la fila,
-- marcar a alguien como atendido, o borrar un turno.
drop policy if exists "turnos_lectura_autenticada" on turnos;
create policy "turnos_lectura_autenticada" on turnos
  for select using (auth.role() = 'authenticated');

drop policy if exists "turnos_actualizacion_autenticada" on turnos;
create policy "turnos_actualizacion_autenticada" on turnos
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "turnos_borrado_autenticado" on turnos;
create policy "turnos_borrado_autenticado" on turnos
  for delete using (auth.role() = 'authenticated');

-- Cualquier persona (sin sesión) puede tomar un turno escribiendo su
-- nombre, desde tomar-turno.html (QR del mostrador). El número, la fecha y
-- el estado los pone el trigger de arriba, no el navegador del cliente.
drop policy if exists "turnos_creacion_publica" on turnos;
create policy "turnos_creacion_publica" on turnos
  for insert
  with check (nombre is not null and length(trim(nombre)) > 0);

-- La pantalla de la sala de espera (pantalla-turnos.html) también es
-- pública, sin login, y solo necesita ver los turnos del día de hoy.
drop policy if exists "turnos_lectura_publica_hoy" on turnos;
create policy "turnos_lectura_publica_hoy" on turnos
  for select using (fecha = current_date);

notify pgrst, 'reload schema';
