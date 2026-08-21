-- Contenido editable de la página web pública (bienvenida.html): fotos que
-- el dueño puede subir desde el panel (Configuración -> Página web) y textos
-- editables (sobre nosotros, franja de promoción, link de reseñas de Google).
-- Todo se guarda en configuracion_negocio, igual que el resto de los datos
-- del negocio, para reusar el mismo patrón de lectura/guardado que ya existe.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

insert into storage.buckets (id, name, public)
values ('fotos-web-publica', 'fotos-web-publica', true)
on conflict (id) do nothing;

drop policy if exists "lectura_publica_fotos_web_publica" on storage.objects;
create policy "lectura_publica_fotos_web_publica" on storage.objects
  for select using (bucket_id = 'fotos-web-publica');

drop policy if exists "subir_fotos_web_publica_autenticado" on storage.objects;
create policy "subir_fotos_web_publica_autenticado" on storage.objects
  for insert with check (bucket_id = 'fotos-web-publica' and auth.role() = 'authenticated');

drop policy if exists "eliminar_fotos_web_publica_autenticado" on storage.objects;
create policy "eliminar_fotos_web_publica_autenticado" on storage.objects
  for delete using (bucket_id = 'fotos-web-publica' and auth.role() = 'authenticated');

alter table configuracion_negocio add column if not exists web_foto_hero_url text;
alter table configuracion_negocio add column if not exists web_foto_equipo_url text;
alter table configuracion_negocio add column if not exists web_sobre_nosotros_texto text;
alter table configuracion_negocio add column if not exists web_promo_banner_texto text;
alter table configuracion_negocio add column if not exists web_promo_banner_activo boolean not null default false;
alter table configuracion_negocio add column if not exists web_foto_chasis_url text;
alter table configuracion_negocio add column if not exists web_foto_frenos_url text;
alter table configuracion_negocio add column if not exists web_foto_pintura_url text;
alter table configuracion_negocio add column if not exists web_foto_antes_despues_url text;
alter table configuracion_negocio add column if not exists web_foto_trabajo_1_url text;
alter table configuracion_negocio add column if not exists web_foto_trabajo_2_url text;
alter table configuracion_negocio add column if not exists web_foto_trabajo_3_url text;
alter table configuracion_negocio add column if not exists web_foto_trabajo_4_url text;
alter table configuracion_negocio add column if not exists web_google_reviews_url text;

notify pgrst, 'reload schema';
