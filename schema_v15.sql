-- Endurece el acceso: las tablas internas del taller ya solo se pueden leer
-- o editar con una sesión real de empleado (no solo con la anon key, que
-- viaja pública en el navegador). Se aplica DESPUÉS de confirmar que el
-- login individual (My Account) ya funciona, para no dejar a nadie afuera.
--
-- Facturas/factura_items/estimados/estimado_items quedan SIN cambios a
-- propósito: siguen siendo de acceso público (using true), porque los
-- clientes las ven/aprueban desde un link sin iniciar sesión
-- (ver-factura.html / ver-estimado.html). Eso es intencional, no un hueco.
--
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter policy "acceso_compartido_clientes" on clientes
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_vehiculos" on vehiculos
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_ordenes_servicio" on ordenes_servicio
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_orden_piezas" on orden_piezas
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_piezas" on piezas
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_tareas" on tareas
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_gastos" on gastos
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_configuracion_negocio" on configuracion_negocio
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
alter policy "acceso_compartido_citas" on citas
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

notify pgrst, 'reload schema';
