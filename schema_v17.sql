-- Registra qué empleado creó cada orden de servicio y cada factura.
-- Solo hacia adelante (no se rellena el historial viejo).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table ordenes_servicio add column if not exists creado_por uuid references empleados(id);
alter table facturas add column if not exists creado_por uuid references empleados(id);

notify pgrst, 'reload schema';
