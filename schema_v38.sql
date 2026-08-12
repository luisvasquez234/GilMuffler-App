-- Guarda la fecha real en que se marcó una factura como pagada (antes solo
-- se sabía la fecha de creación de la factura, no cuándo se cobró). La usa
-- la pantalla nueva "Paid Invoices" para mostrar cuándo se pagó cada una.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table facturas add column if not exists fecha_pagada date;

notify pgrst, 'reload schema';
