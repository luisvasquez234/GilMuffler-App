-- Agrega "Pago mecánico" al Registro diario: lo que el mecánico se lleva
-- de pago/comisión por ese trabajo específico. Es distinto de
-- "Dinero de salida" (que ya existía) — ese es dinero que sale de la caja
-- del taller, no lo que gana el mecánico.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table registro_diario_items add column if not exists pago_mecanico numeric(10,2) not null default 0;

notify pgrst, 'reload schema';
