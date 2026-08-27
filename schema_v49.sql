-- Convierte "Nuestro trabajo" en la página pública de 4 espacios fijos de
-- foto a una galería real: subís las fotos que quieras, sin límite, y el
-- cliente las ve todas. Reusa el mismo bucket de Storage que ya existe
-- (fotos-web-publica), solo con una carpeta nueva (galeria-trabajo/) —
-- no hace falta crear un bucket ni políticas de Storage nuevas.
-- Las 4 fotos que ya hubiera subidas en los espacios viejos se migran
-- automáticamente a la galería para no perderlas.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists galeria_trabajo_fotos (
  id uuid primary key default gen_random_uuid(),
  url text not null,
  storage_path text not null,
  orden integer not null default 0,
  created_at timestamptz not null default now()
);

alter table galeria_trabajo_fotos enable row level security;

drop policy if exists "galeria_trabajo_lectura_publica" on galeria_trabajo_fotos;
create policy "galeria_trabajo_lectura_publica" on galeria_trabajo_fotos
  for select using (true);

drop policy if exists "galeria_trabajo_escritura_autenticada" on galeria_trabajo_fotos;
create policy "galeria_trabajo_escritura_autenticada" on galeria_trabajo_fotos
  for all
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());

create index if not exists idx_galeria_trabajo_orden on galeria_trabajo_fotos (orden, created_at);

-- Migrar las fotos que ya estuvieran en los 4 espacios fijos viejos.
insert into galeria_trabajo_fotos (url, storage_path, orden)
select
  c.web_foto_trabajo_1_url,
  regexp_replace(c.web_foto_trabajo_1_url, '^.*/fotos-web-publica/', ''),
  1
from configuracion_negocio c
where c.id = 1 and c.web_foto_trabajo_1_url is not null
  and not exists (select 1 from galeria_trabajo_fotos g where g.url = c.web_foto_trabajo_1_url);

insert into galeria_trabajo_fotos (url, storage_path, orden)
select
  c.web_foto_trabajo_2_url,
  regexp_replace(c.web_foto_trabajo_2_url, '^.*/fotos-web-publica/', ''),
  2
from configuracion_negocio c
where c.id = 1 and c.web_foto_trabajo_2_url is not null
  and not exists (select 1 from galeria_trabajo_fotos g where g.url = c.web_foto_trabajo_2_url);

insert into galeria_trabajo_fotos (url, storage_path, orden)
select
  c.web_foto_trabajo_3_url,
  regexp_replace(c.web_foto_trabajo_3_url, '^.*/fotos-web-publica/', ''),
  3
from configuracion_negocio c
where c.id = 1 and c.web_foto_trabajo_3_url is not null
  and not exists (select 1 from galeria_trabajo_fotos g where g.url = c.web_foto_trabajo_3_url);

insert into galeria_trabajo_fotos (url, storage_path, orden)
select
  c.web_foto_trabajo_4_url,
  regexp_replace(c.web_foto_trabajo_4_url, '^.*/fotos-web-publica/', ''),
  4
from configuracion_negocio c
where c.id = 1 and c.web_foto_trabajo_4_url is not null
  and not exists (select 1 from galeria_trabajo_fotos g where g.url = c.web_foto_trabajo_4_url);

notify pgrst, 'reload schema';
