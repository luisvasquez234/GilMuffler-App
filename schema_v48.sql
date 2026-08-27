-- Dos datos reales para el nuevo bloque de "números" en la página pública
-- (bienvenida.html): años de experiencia y carros atendidos. Se editan
-- desde el panel (Configuración > Página web), igual que "Sobre nosotros".
-- Si quedan vacíos, ese número simplemente no se muestra en la página.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists web_anios_experiencia text;
alter table configuracion_negocio add column if not exists web_carros_atendidos text;

notify pgrst, 'reload schema';
