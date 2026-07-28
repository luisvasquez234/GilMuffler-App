# Ideas para mejorar la app de Gil Muffler

Lista de mejoras posibles, para revisar y decidir cuáles implementar más
adelante. No es necesario hacerlas todas ni en este orden — es solo un menú
de opciones. Cada una tiene: qué es, por qué sirve, tamaño aproximado del
trabajo (chico/mediano/grande) y qué depende de algo externo (cuenta,
tarjeta, etc.) antes de poder hacerse.

**Hecho ya** (para no repetir): email automático de factura al marcar como
pagada (Resend, dominio verificado); apellido y vehículo obligatorios al
crear cliente; menú de "3 puntos" ya no se corta en la última fila;
**Export** (CSV de clientes/vehículos/facturas/órdenes desde el navegador);
**Estimates/presupuestos aprobables en línea** (punto 8, con link público
para aprobar/rechazar y "convertir a factura"); **Bookings/reservas** (agenda
de citas por Hoy/Esta semana/Más adelante, cubre el espíritu del punto 14);
**login individual por empleado** (punto 20 — My Account, con Supabase Auth
real y RLS endurecido en las tablas internas del taller; facturas/estimados
siguen siendo de acceso público a propósito, por los links para clientes);
**alertas de stock bajo por email** (cron diario); **historial de
kilometraje** con fecha; **reporte de clientes inactivos** (checkbox en
Clientes); **búsqueda global** ampliada a Estimates y Bookings; **registrar
quién creó cada orden/factura**; **PWA instalable**; **página pública de
estado de orden** (`ver-orden.html`); **checklist de inspección** (frenos,
luces, llantas, fluidos); **reporte de rotación de inventario**.

## Comunicación con clientes

1. **Avisar por WhatsApp/SMS cuando el carro está listo** — mensaje automático
   al cambiar una orden a "completado". Tamaño: mediano. Depende de: activar
   Twilio (ya se decidió que sí, con tarjeta) — pendiente terminar esa
   configuración.
2. **Recordatorio automático de mantenimiento** — un cron revisa
   `kilometraje`/fecha del último servicio y manda un email tipo "ya se acerca
   tu próximo cambio de aceite". Tamaño: mediano. Depende de: definir la regla
   (cada cuántos meses/millas) — decisión de negocio, no técnica.
3. **Link para dejar reseña en Google después de facturar** — el mismo email
   de factura (ya existe) agrega un botón "Déjanos una reseña". Tamaño: chico.
   Depende de: el link de reseña de Google Business del taller.
4. ~~**Página pública de estado de orden**~~ — **YA HECHO** (`ver-orden.html`,
   con los pasos diagnóstico → reparando → listo, sin login).
5. ~~**Reporte de clientes inactivos**~~ — **YA HECHO** (checkbox "Solo
   inactivos" en Clientes, con columna de última factura).

## Facturación y pagos

6. **Botón de "pagar en línea"** (Stripe o PayPal) en la factura pública, para
   que el cliente pague sin ir al taller. Tamaño: grande. Depende de: cuenta
   de Stripe/PayPal verificada (papeleo bancario).
7. **Firma digital al recoger el vehículo** — captura de firma en pantalla
   (touch/mouse) como comprobante de entrega, guardada con la orden. Tamaño:
   mediano.
8. ~~**Presupuestos aprobables en línea**~~ — **YA HECHO** (Estimates: nueva
   tabla, link público para aprobar/rechazar, botón "Convertir a factura").
9. **Historial de precios de piezas** — ver cuándo subió de precio un
   proveedor, a partir del historial de `piezas`/`orden_piezas`. Tamaño:
   chico-mediano.
10. **Calculadora de garantía** — avisar si una pieza instalada sigue en
    garantía al momento de un reclamo. Tamaño: mediano. Depende de: que cada
    pieza tenga meses/millas de garantía capturados (dato nuevo a llenar).

## Vehículos y órdenes de servicio

11. ~~**Historial completo de kilometraje**~~ — **YA HECHO** (tabla
    `kilometraje_historial`, se ve en la ficha del vehículo).
12. **Fotos antes/después en la orden** — subir 2-3 fotos como evidencia del
    trabajo hecho, usando Supabase Storage. Tamaño: mediano.
13. ~~**Checklist de inspección por orden**~~ — **YA HECHO** (frenos, luces,
    llantas, fluidos, en el modal de la orden).
14. ~~**Vista de calendario semanal**~~ — **YA HECHO** como agenda de
    reservas (Bookings: Hoy / Esta semana / Más adelante). Si más adelante se
    quiere un calendario tipo cuadrícula de verdad, eso sería un proyecto
    aparte más grande.
15. ~~**Búsqueda global**~~ — **YA HECHO** (ya existía para Clientes/
    Órdenes/Facturas, se amplió a Estimates y Bookings).

## Reportes y finanzas

16. **Reporte de ganancias por tipo de servicio/pieza** — qué servicio deja
    más margen. Tamaño: mediano (requiere separar costo vs. precio de venta
    de forma consistente).
17. ~~**Reporte de rotación de inventario**~~ — **YA HECHO** (botón "Ver
    rotación de inventario" en Inventario, piezas usadas de más a menos).
18. ~~**Exportar datos a CSV**~~ — **YA HECHO** (sección Export: clientes,
    vehículos, facturas, órdenes). Falta, si se quiere después, un reporte de
    impuestos ya calculado por periodo (no solo el CSV crudo de facturas).
19. ~~**Alertas de stock bajo por email**~~ — **YA HECHO** (cron diario entre
    semana, ver `.github/workflows/alerta-stock.yml`).

## Usuarios y seguridad

20. ~~**Login individual por empleado**~~ — **YA HECHO** (My Account:
    Supabase Auth real con email+contraseña por empleado, tabla `empleados`,
    y las tablas internas del taller ya exigen sesión iniciada — antes
    cualquiera con la anon key podía leer/escribir todo).
21. ~~**Registrar qué empleado hizo cada orden/factura**~~ — **YA HECHO**
    (columna `creado_por`, se muestra "Creada por: X" en el modal).
22. **Calculadora de comisiones por empleado** — depende de #20 y #21 (ambos
    hechos), falta solo la lógica de cálculo (¿% fijo? ¿por tipo de servicio?
    — decisión de negocio antes de construirla).
23. ~~**Respaldo automático de datos**~~ — **YA HECHO** (cron semanal por
    email, ver `.github/workflows/respaldo-semanal.yml`).

## Técnico / infraestructura

24. ~~**Instalar la app como PWA**~~ — **YA HECHO** (`manifest.json` +
    service worker; en el celular usa "Agregar a pantalla de inicio" desde
    el navegador).
25. **Modo básico sin internet** — que la app siga funcionando (aunque sea
    para consultar, no guardar) si se cae el WiFi del taller. Tamaño: grande
    (requiere repensar cómo se guardan los datos localmente).

---

### Ideas más chicas, sin numerar (quedaron fuera del top 25 pero valen la pena)
- Sistema de puntos/descuentos para clientes frecuentes.
- Bot de WhatsApp real vía Twilio para el negocio de diseño web de Luis
  (código ya escrito en `supabase/functions/whatsapp-bot`, pendiente decisión
  de pagar Twilio — ver punto 1, mismo bloqueo).
