-- Agrega método de pago a las facturas (efectivo/tarjeta/cheque), para saber
-- cómo se cobró cada factura pagada y así saber cómo hacer una devolución si
-- hace falta más adelante.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table facturas add column if not exists metodo_pago text check (metodo_pago in ('efectivo','tarjeta','cheque'));

notify pgrst, 'reload schema';
