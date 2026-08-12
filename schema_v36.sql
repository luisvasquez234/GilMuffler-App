-- Da a las cuentas de "mecánico" acceso limitado: solo pueden iniciar sesión
-- para mandar un reporte de trabajo (reportar-trabajo.html) y leer el
-- nombre de los mecánicos (para mostrarlo en esa misma pantalla). No pueden
-- ver ni editar clientes, facturas, órdenes, presupuestos, inventario,
-- gastos, configuración, otros empleados, ni el Registro diario completo.
--
-- Las cuentas de "encargado" (Luis y cualquier empleado sin rol asignado)
-- NO pierden nada — quedan exactamente igual que antes.
--
-- Nota: facturas/factura_items/estimados/estimado_items/ordenes_servicio ya
-- tenían LECTURA pública desde antes (sin necesitar sesión, para que
-- ver-factura.html etc. funcionen) — eso no cambia aquí y no es un hueco
-- nuevo. Lo que se cierra para "mecánico" es la ESCRITURA (crear/editar/
-- borrar) de esas tablas, y el acceso completo (lectura+escritura) a las
-- que eran solo-empleados.
--
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

begin;

-- 1) Rol por cuenta de empleado. Por default "encargado" (acceso completo,
--    como siempre) para no dejar a nadie fuera por accidente.
alter table empleados add column if not exists rol text not null default 'encargado';

update empleados set rol = 'mecanico'
where email in ('ysidro@gilmuffler.com', 'quide@gilmuffler.com', 'joan@gilmuffler.com', 'victor@gilmuffler.com');

-- 2) Función auxiliar para usar dentro de las políticas de RLS. Es
--    "security definer" a propósito: necesita poder leer la tabla
--    "empleados" aunque la política de esa misma tabla ya no deje leer a
--    un mecánico directamente (si no, la función nunca podría confirmar
--    que ES mecánico).
create or replace function is_mecanico()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select rol = 'mecanico' from empleados where id = auth.uid()), false);
$$;

grant execute on function is_mecanico() to authenticated;

-- 3) Tablas de acceso completo solo-empleado: se cierran del todo para
--    "mecánico" (ni lectura ni escritura).
alter policy "acceso_compartido_clientes" on clientes
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_vehiculos" on vehiculos
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_orden_piezas" on orden_piezas
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_piezas" on piezas
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_tareas" on tareas
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_gastos" on gastos
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_citas" on citas
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_cliente_telefonos" on cliente_telefonos
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "empleados_autenticados" on empleados
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_kilometraje_historial" on kilometraje_historial
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_pieza_precio_historial" on pieza_precio_historial
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_registro_diario" on registro_diario
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_registro_diario_items" on registro_diario_items
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_orden_fotos" on orden_fotos
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "acceso_compartido_llamadas_ordenes" on llamadas_ordenes
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());

-- 4) Tablas con lectura pública (sin cambios) + escritura solo-empleado:
--    se cierra la ESCRITURA para "mecánico". La lectura pública sigue
--    igual para todo el mundo (eso ya era así antes, no es nuevo).
alter policy "facturas_escritura_autenticada" on facturas
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "facturas_actualizacion_autenticada" on facturas
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "facturas_borrado_autenticado" on facturas
  using (auth.role() = 'authenticated' and not is_mecanico());

alter policy "factura_items_escritura_autenticada" on factura_items
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "factura_items_actualizacion_autenticada" on factura_items
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "factura_items_borrado_autenticado" on factura_items
  using (auth.role() = 'authenticated' and not is_mecanico());

alter policy "estimados_escritura_autenticada" on estimados
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "estimados_actualizacion_autenticada" on estimados
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "estimados_borrado_autenticado" on estimados
  using (auth.role() = 'authenticated' and not is_mecanico());

alter policy "estimado_items_escritura_autenticada" on estimado_items
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "estimado_items_actualizacion_autenticada" on estimado_items
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "estimado_items_borrado_autenticado" on estimado_items
  using (auth.role() = 'authenticated' and not is_mecanico());

alter policy "ordenes_servicio_escritura_autenticada" on ordenes_servicio
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "ordenes_servicio_actualizacion_autenticada" on ordenes_servicio
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "ordenes_servicio_borrado_autenticado" on ordenes_servicio
  using (auth.role() = 'authenticated' and not is_mecanico());

alter policy "configuracion_negocio_escritura_autenticada" on configuracion_negocio
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "configuracion_negocio_actualizacion_autenticada" on configuracion_negocio
  using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
alter policy "configuracion_negocio_borrado_autenticado" on configuracion_negocio
  using (auth.role() = 'authenticated' and not is_mecanico());

-- 5) Fotos: un mecánico no necesita subir/borrar fotos de órdenes ni de la
--    hoja del registro diario (eso lo sigue haciendo el encargado).
alter policy "subir_fotos_ordenes_autenticado" on storage.objects
  with check (bucket_id = 'fotos-ordenes' and auth.role() = 'authenticated' and not is_mecanico());
alter policy "eliminar_fotos_ordenes_autenticado" on storage.objects
  using (bucket_id = 'fotos-ordenes' and auth.role() = 'authenticated' and not is_mecanico());
alter policy "subir_fotos_registro_diario_autenticado" on storage.objects
  with check (bucket_id = 'fotos-registro-diario' and auth.role() = 'authenticated' and not is_mecanico());
alter policy "eliminar_fotos_registro_diario_autenticado" on storage.objects
  using (bucket_id = 'fotos-registro-diario' and auth.role() = 'authenticated' and not is_mecanico());

-- 6) mecanicos: un mecánico SÍ necesita poder leer los nombres (para que
--    reportar-trabajo.html le muestre "Ysidro — 2026-08-11"), pero no
--    necesita crear/editar/borrar mecánicos.
drop policy if exists "acceso_compartido_mecanicos" on mecanicos;
create policy "mecanicos_lectura_autenticada" on mecanicos
  for select using (auth.role() = 'authenticated');
create policy "mecanicos_escritura_autenticada" on mecanicos
  for insert with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "mecanicos_actualizacion_autenticada" on mecanicos
  for update using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "mecanicos_borrado_autenticado" on mecanicos
  for delete using (auth.role() = 'authenticated' and not is_mecanico());

-- 7) reportes_trabajo: al revés que las demás — un mecánico SÍ necesita
--    poder MANDAR (insertar) su reporte, pero no necesita ver ni editar
--    los reportes (eso lo revisa el encargado en Registro diario).
drop policy if exists "acceso_compartido_reportes_trabajo" on reportes_trabajo;
create policy "reportes_trabajo_creacion_autenticada" on reportes_trabajo
  for insert with check (auth.role() = 'authenticated');
create policy "reportes_trabajo_lectura_autenticada" on reportes_trabajo
  for select using (auth.role() = 'authenticated' and not is_mecanico());
create policy "reportes_trabajo_actualizacion_autenticada" on reportes_trabajo
  for update using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());
create policy "reportes_trabajo_borrado_autenticado" on reportes_trabajo
  for delete using (auth.role() = 'authenticated' and not is_mecanico());

commit;

notify pgrst, 'reload schema';
