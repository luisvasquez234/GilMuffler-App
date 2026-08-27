-- Encuesta rápida de satisfacción: cuando una orden queda "completado" (o
-- "facturado"), el cliente puede calificarla del 1 al 5 con un comentario
-- opcional desde ver-orden.html (sin necesidad de iniciar sesión).
-- Las respuestas NO son públicas — solo el taller (con sesión iniciada,
-- excepto cuentas de mecánico) puede leerlas. Un disparador (trigger)
-- marca la orden como "ya respondida" automáticamente, así el cliente no
-- ve el formulario dos veces sin necesitar que la página pública pueda
-- editar la orden directamente.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table ordenes_servicio add column if not exists encuesta_respondida boolean not null default false;

create table if not exists encuestas_satisfaccion (
  id uuid primary key default gen_random_uuid(),
  orden_id uuid not null references ordenes_servicio(id) on delete cascade,
  puntaje integer not null check (puntaje between 1 and 5),
  comentario text,
  created_at timestamptz not null default now()
);

alter table encuestas_satisfaccion enable row level security;

drop policy if exists "encuestas_insercion_publica" on encuestas_satisfaccion;
create policy "encuestas_insercion_publica" on encuestas_satisfaccion
  for insert with check (true);

drop policy if exists "encuestas_lectura_autenticada" on encuestas_satisfaccion;
create policy "encuestas_lectura_autenticada" on encuestas_satisfaccion
  for select using (auth.role() = 'authenticated' and not is_mecanico());

create or replace function marcar_orden_encuesta_respondida()
returns trigger as $$
begin
  update ordenes_servicio set encuesta_respondida = true where id = new.orden_id;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists trg_marcar_encuesta_respondida on encuestas_satisfaccion;
create trigger trg_marcar_encuesta_respondida
  after insert on encuestas_satisfaccion
  for each row execute function marcar_orden_encuesta_respondida();

notify pgrst, 'reload schema';
