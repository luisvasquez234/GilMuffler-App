-- Agrega la tasa de impuesto por defecto y rellena los datos reales del
-- negocio (tomados del sistema de facturación que ya usan: AutoRepairBill).
-- Seguro de correr sin importar qué otras migraciones ya se hayan aplicado.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists tasa_impuesto_default numeric(5,2) not null default 0;

update configuracion_negocio
set
  nombre_negocio = 'Gil''s Muffler Inc',
  direccion = '5 Oxford St, Lawrence, MA 01841',
  telefono = '978-683-2401',
  email = 'gilmuffler@hotmail.com',
  texto_adicional = coalesce(nullif(texto_adicional, ''), 'Garantía: Labor 45 días · Piezas 1 año'),
  tasa_impuesto_default = 4.25,
  updated_at = now()
where id = 1;

notify pgrst, 'reload schema';
