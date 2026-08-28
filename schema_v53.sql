-- Muestra en la página web pública un resumen ("★ 4.8 basado en 32 reseñas")
-- de las encuestas de satisfacción, SIN exponer los comentarios individuales
-- ni abrir la tabla completa a la anon key — las respuestas siguen siendo
-- privadas (solo el taller las lee una por una), como ya decía schema_v51.
-- Esta función solo calcula un promedio y un total; no devuelve ninguna fila
-- real de la tabla.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create or replace function calificacion_publica_resumen()
returns table(promedio numeric, total integer)
language sql
security definer
set search_path = public
as $$
  select coalesce(avg(puntaje), 0)::numeric(3,2), count(*)::integer from encuestas_satisfaccion;
$$;

grant execute on function calificacion_publica_resumen() to anon;

notify pgrst, 'reload schema';
