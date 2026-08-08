-- Agrega dos campos opcionales de configuración para rediseñar la factura
-- impresa al estilo del sistema viejo (AutoRepairBill): garantía de mano de
-- obra por separado de la garantía de piezas, y un número fiscal opcional
-- (Tax ID / EIN) que solo se muestra en la factura si se llena.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists garantia_labor_dias integer not null default 45;
alter table configuracion_negocio add column if not exists numero_fiscal text;

notify pgrst, 'reload schema';
