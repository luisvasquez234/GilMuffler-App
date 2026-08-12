-- Tres cosas nuevas en facturas:
-- 1) etiquetas rápidas (texto separado por comas, igual que en clientes)
-- 2) pago dividido entre dos métodos (ej. mitad efectivo, mitad tarjeta)
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table facturas add column if not exists etiquetas text;
alter table facturas add column if not exists monto_metodo_1 numeric(10,2);
alter table facturas add column if not exists metodo_pago_2 text check (metodo_pago_2 in ('efectivo','tarjeta','cheque'));
alter table facturas add column if not exists monto_metodo_2 numeric(10,2);

notify pgrst, 'reload schema';
