-- Vincula cada factura con el mecánico que hizo el trabajo, para poder
-- mostrarlo impreso en la factura.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table facturas add column if not exists mecanico_id uuid references mecanicos(id);

notify pgrst, 'reload schema';
