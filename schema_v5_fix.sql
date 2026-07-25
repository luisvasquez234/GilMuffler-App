-- Reemplaza la tabla de configuración por una versión más simple y confiable.
-- Es seguro correr esto (la tabla es nueva, no tiene datos importantes todavía).
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

drop table if exists configuracion_negocio;

create table configuracion_negocio (
  id integer primary key default 1,
  nombre_negocio text,
  direccion text,
  telefono text,
  email text,
  mensaje_pie text,
  updated_at timestamptz not null default now(),
  constraint configuracion_negocio_single_row check (id = 1)
);

insert into configuracion_negocio (id, nombre_negocio, mensaje_pie)
values (1, 'Gil Muffler', '¡Gracias por su preferencia!');

alter table configuracion_negocio enable row level security;

drop policy if exists "acceso_compartido_configuracion_negocio" on configuracion_negocio;
create policy "acceso_compartido_configuracion_negocio" on configuracion_negocio
  for all using (true) with check (true);

-- Fuerza a Supabase a refrescar su caché para que vea la tabla nueva de inmediato.
notify pgrst, 'reload schema';
