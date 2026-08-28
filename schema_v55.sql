-- Extiende la galería de "Nuestro trabajo" para admitir videos (guardados
-- como links de YouTube, no archivos subidos — así no hay límite de espacio
-- ni de costo) y para poder etiquetar cada foto/video con el carro (marca,
-- modelo, año), de forma que el cliente pueda buscar en la página web.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table galeria_trabajo_fotos add column if not exists tipo text not null default 'foto' check (tipo in ('foto', 'video'));
alter table galeria_trabajo_fotos add column if not exists youtube_id text;
alter table galeria_trabajo_fotos add column if not exists vehiculo_marca text;
alter table galeria_trabajo_fotos add column if not exists vehiculo_modelo text;
alter table galeria_trabajo_fotos add column if not exists vehiculo_anio text;

-- Los videos no tienen storage_path (no se suben archivos, solo se guarda el
-- link de YouTube), así que esa columna ya no puede ser obligatoria.
alter table galeria_trabajo_fotos alter column storage_path drop not null;

notify pgrst, 'reload schema';
