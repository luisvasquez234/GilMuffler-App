-- configuracion_negocio quedó restringida a solo usuarios con sesión
-- iniciada desde schema_v15.sql. Esa tabla no tiene datos sensibles (nombre,
-- dirección, teléfono, logo, colores de impresión) y es justo lo que las
-- páginas públicas (ver-factura.html, ver-orden.html, ver-estimado.html,
-- llamame.html) necesitan leer para mostrar el logo/nombre real del negocio
-- en vez de los valores genéricos de respaldo. Se abre solo la LECTURA;
-- seguir necesitando sesión para editarla desde Configuración.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

drop policy if exists "acceso_compartido_configuracion_negocio" on configuracion_negocio;
create policy "configuracion_negocio_lectura_publica" on configuracion_negocio
  for select using (true);
create policy "configuracion_negocio_escritura_autenticada" on configuracion_negocio
  for insert with check (auth.role() = 'authenticated');
create policy "configuracion_negocio_actualizacion_autenticada" on configuracion_negocio
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "configuracion_negocio_borrado_autenticado" on configuracion_negocio
  for delete using (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
