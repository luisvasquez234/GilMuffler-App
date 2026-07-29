-- Fotos del vehículo dentro de una orden de servicio (Supabase Storage +
-- tabla de metadatos). Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

insert into storage.buckets (id, name, public)
values ('fotos-ordenes', 'fotos-ordenes', true)
on conflict (id) do nothing;

drop policy if exists "lectura_publica_fotos_ordenes" on storage.objects;
create policy "lectura_publica_fotos_ordenes" on storage.objects
  for select using (bucket_id = 'fotos-ordenes');

drop policy if exists "subir_fotos_ordenes_autenticado" on storage.objects;
create policy "subir_fotos_ordenes_autenticado" on storage.objects
  for insert with check (bucket_id = 'fotos-ordenes' and auth.role() = 'authenticated');

drop policy if exists "eliminar_fotos_ordenes_autenticado" on storage.objects;
create policy "eliminar_fotos_ordenes_autenticado" on storage.objects
  for delete using (bucket_id = 'fotos-ordenes' and auth.role() = 'authenticated');

create table if not exists orden_fotos (
  id uuid primary key default gen_random_uuid(),
  orden_id uuid not null references ordenes_servicio(id) on delete cascade,
  url text not null,
  storage_path text not null,
  created_at timestamptz not null default now()
);

alter table orden_fotos enable row level security;

drop policy if exists "acceso_compartido_orden_fotos" on orden_fotos;
create policy "acceso_compartido_orden_fotos" on orden_fotos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
