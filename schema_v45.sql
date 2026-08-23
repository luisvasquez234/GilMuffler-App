-- Campos nuevos para la página web pública: dos fotos separadas para el
-- comparador "antes/después" (reemplaza el campo único anterior, que queda
-- sin usar pero no se borra), y 3 reseñas reales opcionales para mostrar en
-- un carrusel en vez de la nota de "todavía no hay reseñas".
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists web_foto_antes_url text;
alter table configuracion_negocio add column if not exists web_foto_despues_url text;
alter table configuracion_negocio add column if not exists web_resena_1_texto text;
alter table configuracion_negocio add column if not exists web_resena_1_autor text;
alter table configuracion_negocio add column if not exists web_resena_2_texto text;
alter table configuracion_negocio add column if not exists web_resena_2_autor text;
alter table configuracion_negocio add column if not exists web_resena_3_texto text;
alter table configuracion_negocio add column if not exists web_resena_3_autor text;

notify pgrst, 'reload schema';
