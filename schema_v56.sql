-- Arregla el QR del cliente (ver-cliente.html): la página ya podía leer los
-- datos del cliente en público desde v52, pero "vehiculos" y "citas" se
-- quedaron cerradas a solo-empleado desde v36, así que un cliente que
-- escaneaba su QR sin sesión iniciada nunca veía sus carros ni su próxima
-- cita (la consulta volvía vacía, sin ningún error).
--
-- Mismo patrón que v52 uso para "clientes": lectura pública total en la
-- tabla, seguridad real = el id del cliente es un UUID imposible de
-- adivinar. Crear/editar/borrar sigue exigiendo sesión de empleado (y sigue
-- bloqueado para cuentas de "mecánico", igual que antes).
--
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

drop policy if exists "acceso_compartido_vehiculos" on vehiculos;

create policy "vehiculos_lectura_publica" on vehiculos
  for select using (true);

create policy "vehiculos_escritura_autenticada" on vehiculos
  for insert with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "vehiculos_actualizacion_autenticada" on vehiculos
  for update using (auth.role() = 'authenticated' and not is_mecanico()) with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "vehiculos_borrado_autenticado" on vehiculos
  for delete using (auth.role() = 'authenticated' and not is_mecanico());

drop policy if exists "acceso_compartido_citas" on citas;

create policy "citas_lectura_publica" on citas
  for select using (true);

create policy "citas_escritura_autenticada" on citas
  for insert with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "citas_actualizacion_autenticada" on citas
  for update using (auth.role() = 'authenticated' and not is_mecanico()) with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "citas_borrado_autenticado" on citas
  for delete using (auth.role() = 'authenticated' and not is_mecanico());

notify pgrst, 'reload schema';
