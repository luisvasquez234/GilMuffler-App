-- Configuración del negocio (una sola fila), usada para personalizar la factura
-- impresa: nombre, dirección, teléfono, email y mensaje de pie de página.
-- Seguro de correr sin importar qué otras migraciones ya se hayan aplicado.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists configuracion_negocio (
  id boolean primary key default true,
  nombre_negocio text,
  direccion text,
  telefono text,
  email text,
  mensaje_pie text,
  updated_at timestamptz not null default now(),
  constraint configuracion_negocio_single_row check (id)
);

insert into configuracion_negocio (id, nombre_negocio, mensaje_pie)
values (true, 'Gil Muffler', '¡Gracias por su preferencia!')
on conflict (id) do nothing;

alter table configuracion_negocio enable row level security;

drop policy if exists "acceso_compartido_configuracion_negocio" on configuracion_negocio;
create policy "acceso_compartido_configuracion_negocio" on configuracion_negocio
  for all using (true) with check (true);
