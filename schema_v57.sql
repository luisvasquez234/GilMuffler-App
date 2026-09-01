-- Agrega opciones de configuración pedidas por Luis, inspiradas en la
-- pantalla de "Settings" del sistema viejo (AutoRepairBill):
--   - mostrar_horas_mano_obra: si la factura impresa muestra las horas de
--     cada línea de mano de obra (hoy se capturan pero nunca se imprimen).
--   - mostrar_numero_fiscal: interruptor aparte para ocultar/mostrar el
--     número fiscal en la factura, aunque esté guardado en numero_fiscal.
--   - mostrar_numero_factura: interruptor para ocultar el número de
--     factura al imprimir.
--   - mostrar_qr_orden: si la orden de servicio impresa incluye un QR
--     (las facturas ya tenían su propio interruptor, mostrar_qr).
--   - zona_horaria: zona horaria del negocio, para calcular "hoy" de forma
--     consistente sin depender del reloj del dispositivo que abre la app.
-- Todos con default que preserva el comportamiento actual (numero_fiscal y
-- numero_factura ya se mostraban siempre, así que quedan en true; las horas
-- de mano de obra y el QR de orden son features nuevas, quedan en false).
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

alter table configuracion_negocio add column if not exists mostrar_horas_mano_obra boolean not null default false;
alter table configuracion_negocio add column if not exists mostrar_numero_fiscal boolean not null default true;
alter table configuracion_negocio add column if not exists mostrar_numero_factura boolean not null default true;
alter table configuracion_negocio add column if not exists mostrar_qr_orden boolean not null default false;
alter table configuracion_negocio add column if not exists zona_horaria text not null default 'America/New_York';

notify pgrst, 'reload schema';
