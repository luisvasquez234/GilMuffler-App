-- Más control sobre cómo se ve la factura impresa: color de acento,
-- mostrar/ocultar el código QR, y el título del documento (Factura, Invoice, etc.).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists color_acento text not null default '#d5601a';
alter table configuracion_negocio add column if not exists mostrar_qr boolean not null default true;
alter table configuracion_negocio add column if not exists factura_titulo text not null default 'Factura';

notify pgrst, 'reload schema';
