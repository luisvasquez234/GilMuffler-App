-- Rediseño del formulario de factura: mano de obra y piezas en tablas
-- separadas (con horas/tarifa para labor, y costo/markup% para piezas), más
-- un campo de descuento. Los campos nuevos son solo para mostrar el detalle
-- en el formulario — el total que se guarda y se usa en toda la app sigue
-- siendo el mismo (precio_unitario / subtotal / total), así que las
-- facturas viejas no se rompen, solo no van a tener el detalle de
-- horas/tarifa/costo/markup (se editan como piezas normales si se abren).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table factura_items add column if not exists tipo text not null default 'parte' check (tipo in ('labor','parte'));
alter table factura_items add column if not exists horas numeric(10,2);
alter table factura_items add column if not exists tarifa numeric(10,2);
alter table factura_items add column if not exists costo_unitario numeric(10,2);
alter table factura_items add column if not exists markup_pct numeric(10,2);

-- Reclasifica las filas viejas de "Mano de obra" (antes era un solo campo,
-- no una tabla) para que sigan contando como labor y no como pieza.
update factura_items set tipo = 'labor' where descripcion = 'Mano de obra';

alter table facturas add column if not exists descuento numeric(10,2) not null default 0;

notify pgrst, 'reload schema';
