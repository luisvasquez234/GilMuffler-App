-- v62: foto por pieza del inventario + arreglar el historial de stock.
--
-- pieza_stock_historial tenía RLS activado pero ninguna política en la base
-- real (la de schema_v41 nunca quedó aplicada), así que todo insert/select se
-- rechazaba en silencio y el historial de movimientos nunca se guardó.

alter table piezas add column if not exists foto_url text;

drop policy if exists acceso_compartido_pieza_stock_historial on pieza_stock_historial;
create policy acceso_compartido_pieza_stock_historial on pieza_stock_historial
  for all using (auth.role() = 'authenticated' and not is_mecanico())
  with check (auth.role() = 'authenticated' and not is_mecanico());

notify pgrst, 'reload schema';
