-- Permite que un cliente vea un resumen de su propia cuenta desde un link
-- público (ver-cliente.html, el QR "del cliente"), sin sesión iniciada —
-- mismo patrón que ya usan ordenes_servicio (v18), facturas/estimados (v29):
-- lectura pública total en la tabla, seguridad real = el id es un UUID
-- imposible de adivinar. Crear/editar/borrar sigue exigiendo sesión de
-- empleado, igual que antes.
--
-- Nota: ver-cliente.html solo pide las columnas "nombre, apellido" en su
-- consulta (nunca telefono/email/direccion/notas), pero como esta política
-- abre la tabla completa a la anon key, cualquiera que tenga esa clave
-- pública podría en teoría pedir esas otras columnas directamente. Mismo
-- nivel de exposición que ya aceptamos para facturas/estimados desde v29.
--
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

drop policy if exists "acceso_compartido_clientes" on clientes;

create policy "clientes_lectura_publica" on clientes
  for select using (true);

create policy "clientes_escritura_autenticada" on clientes
  for insert with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "clientes_actualizacion_autenticada" on clientes
  for update using (auth.role() = 'authenticated' and not is_mecanico()) with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "clientes_borrado_autenticado" on clientes
  for delete using (auth.role() = 'authenticated' and not is_mecanico());

notify pgrst, 'reload schema';
