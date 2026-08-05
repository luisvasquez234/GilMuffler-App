-- Cierra el hueco real que quedó pendiente: facturas, factura_items,
-- estimados, estimado_items y cliente_telefonos seguían con
-- "using (true) with check (true)" — cualquiera con la anon key (pública,
-- viaja en el navegador) podía no solo LEER sino también ESCRIBIR/BORRAR
-- cualquier factura, presupuesto o teléfono de cliente, no solo verlos.
--
-- Mismo patrón que ya usa "ordenes_servicio" desde schema_v18:
--   - Lectura pública (solo SELECT) para facturas/factura_items/estimados/
--     estimado_items, porque los clientes las ven desde un link sin
--     iniciar sesión (ver-factura.html / ver-estimado.html). Eso sigue
--     siendo intencional, como ya dice schema_v15.
--   - Crear/editar/borrar sigue exigiendo sesión real de empleado.
--   - Excepción: un cliente público SÍ puede aprobar/rechazar SU propio
--     estimado (cambiar "estado" a aprobado/rechazado) sin iniciar sesión,
--     que es lo único que ver-estimado.html hace sin login. Solo puede
--     tocar estimados que sigan "pendiente", y solo puede dejarlos en
--     aprobado o rechazado — no puede reabrir uno ya respondido.
--   - cliente_telefonos no lo usa ninguna página pública: se cierra igual
--     que "clientes" (solo empleados con sesión).
--
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

-- facturas: lectura pública, escritura solo empleados
drop policy if exists "acceso_compartido_facturas" on facturas;
create policy "facturas_lectura_publica" on facturas
  for select using (true);
create policy "facturas_escritura_autenticada" on facturas
  for insert with check (auth.role() = 'authenticated');
create policy "facturas_actualizacion_autenticada" on facturas
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "facturas_borrado_autenticado" on facturas
  for delete using (auth.role() = 'authenticated');

-- factura_items: igual que facturas
drop policy if exists "acceso_compartido_factura_items" on factura_items;
create policy "factura_items_lectura_publica" on factura_items
  for select using (true);
create policy "factura_items_escritura_autenticada" on factura_items
  for insert with check (auth.role() = 'authenticated');
create policy "factura_items_actualizacion_autenticada" on factura_items
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "factura_items_borrado_autenticado" on factura_items
  for delete using (auth.role() = 'authenticated');

-- estimados: lectura pública + el cliente puede aprobar/rechazar el suyo
drop policy if exists "acceso_compartido_estimados" on estimados;
create policy "estimados_lectura_publica" on estimados
  for select using (true);
create policy "estimados_escritura_autenticada" on estimados
  for insert with check (auth.role() = 'authenticated');
create policy "estimados_respuesta_publica" on estimados
  for update
  using (estado = 'pendiente')
  with check (estado in ('aprobado', 'rechazado'));
create policy "estimados_actualizacion_autenticada" on estimados
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "estimados_borrado_autenticado" on estimados
  for delete using (auth.role() = 'authenticated');

-- estimado_items: lectura pública, escritura solo empleados
drop policy if exists "acceso_compartido_estimado_items" on estimado_items;
create policy "estimado_items_lectura_publica" on estimado_items
  for select using (true);
create policy "estimado_items_escritura_autenticada" on estimado_items
  for insert with check (auth.role() = 'authenticated');
create policy "estimado_items_actualizacion_autenticada" on estimado_items
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "estimado_items_borrado_autenticado" on estimado_items
  for delete using (auth.role() = 'authenticated');

-- cliente_telefonos: ninguna página pública lo usa, cerrar como "clientes"
alter policy "acceso_compartido_cliente_telefonos" on cliente_telefonos
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
