-- Permite ver el estado de una orden de servicio desde un link público
-- (ver-orden.html), sin sesión iniciada — igual que ya pasa con facturas y
-- presupuestos. Solo la LECTURA es pública; crear/editar/borrar sigue
-- exigiendo sesión de empleado.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

drop policy if exists "acceso_compartido_ordenes_servicio" on ordenes_servicio;

create policy "ordenes_servicio_lectura_publica" on ordenes_servicio
  for select using (true);

create policy "ordenes_servicio_escritura_autenticada" on ordenes_servicio
  for insert with check (auth.role() = 'authenticated');
create policy "ordenes_servicio_actualizacion_autenticada" on ordenes_servicio
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "ordenes_servicio_borrado_autenticado" on ordenes_servicio
  for delete using (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
