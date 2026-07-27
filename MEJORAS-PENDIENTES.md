# Ideas para mejorar la app de Gil Muffler

Lista de mejoras posibles, para revisar y decidir cuáles implementar más
adelante. No es necesario hacerlas todas ni en este orden — es solo un menú
de opciones. Cada una tiene: qué es, por qué sirve, tamaño aproximado del
trabajo (chico/mediano/grande) y qué depende de algo externo (cuenta,
tarjeta, etc.) antes de poder hacerse.

**Hecho ya** (para no repetir): email automático de factura al marcar como
pagada (Resend, dominio verificado); apellido y vehículo obligatorios al
crear cliente; menú de "3 puntos" ya no se corta en la última fila.

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
4. **Página pública de estado de orden** — como `ver-factura.html` pero para
   una orden en progreso (diagnóstico → reparando → listo), sin login.
   Tamaño: mediano.
5. **Reporte de clientes inactivos** — lista de clientes sin factura en los
   últimos 90/180 días, para que Luis los contacte él mismo. Tamaño: chico
   (es una consulta + tabla, no manda nada solo).

## Facturación y pagos

6. **Botón de "pagar en línea"** (Stripe o PayPal) en la factura pública, para
   que el cliente pague sin ir al taller. Tamaño: grande. Depende de: cuenta
   de Stripe/PayPal verificada (papeleo bancario).
7. **Firma digital al recoger el vehículo** — captura de firma en pantalla
   (touch/mouse) como comprobante de entrega, guardada con la orden. Tamaño:
   mediano.
8. **Presupuestos aprobables en línea** — el cliente ve un estimado y le da
   "Aprobar" antes de que el taller empiece el trabajo. Tamaño: grande (nueva
   tabla + flujo de estados).
9. **Historial de precios de piezas** — ver cuándo subió de precio un
   proveedor, a partir del historial de `piezas`/`orden_piezas`. Tamaño:
   chico-mediano.
10. **Calculadora de garantía** — avisar si una pieza instalada sigue en
    garantía al momento de un reclamo. Tamaño: mediano. Depende de: que cada
    pieza tenga meses/millas de garantía capturados (dato nuevo a llenar).

## Vehículos y órdenes de servicio

11. **Historial completo de kilometraje** — guardar cada lectura de
    kilometraje con fecha (no solo la última), para ver el ritmo de uso del
    carro. Tamaño: chico (tabla nueva simple).
12. **Fotos antes/después en la orden** — subir 2-3 fotos como evidencia del
    trabajo hecho, usando Supabase Storage. Tamaño: mediano.
13. **Checklist de inspección por orden** — frenos, luces, llantas, fluidos,
    como un formulario rápido dentro de la orden. Tamaño: mediano.
14. **Vista de calendario semanal** — ver las entregas estimadas de la semana
    en un calendario en vez de solo lista. Tamaño: mediano.
15. **Búsqueda global** — un solo cuadro que busca cliente, placa o número de
    factura sin importar en qué sección estés. Tamaño: mediano (afecta varias
    pantallas).

## Reportes y finanzas

16. **Reporte de ganancias por tipo de servicio/pieza** — qué servicio deja
    más margen. Tamaño: mediano (requiere separar costo vs. precio de venta
    de forma consistente).
17. **Reporte de rotación de inventario** — qué piezas se venden rápido vs.
    cuáles llevan meses en el estante. Tamaño: chico-mediano.
18. **Exportar reporte de impuestos** (trimestral/anual) para el contador —
    botón que genera un Excel/CSV con las facturas del periodo. Tamaño:
    chico-mediano.
19. **Alertas de stock bajo por email** — hoy la alerta solo se ve dentro de
    la app; esto la manda por correo (reutiliza Resend, ya configurado).
    Tamaño: chico.

## Usuarios y seguridad

20. **Login individual por empleado** — en vez de una sola contraseña
    compartida, cada quien entra con su usuario. Tamaño: grande (cambia el
    modelo de autenticación de toda la app). Más urgente ahora que el sitio
    es público en internet, no solo la red del taller.
21. **Registrar qué empleado hizo cada orden/factura** — depende de #20 (login
    individual) para tener sentido real.
22. **Calculadora de comisiones por empleado** — depende de #20 y #21.
23. **Respaldo automático de datos** — cron que exporta clientes/facturas/
    órdenes a Excel o PDF cada semana, por si algo sale mal en Supabase.
    Tamaño: chico-mediano (ya existe la infraestructura de crons del proyecto).

## Técnico / infraestructura

24. **Instalar la app como PWA** (ícono en el celular, funciona como app
    nativa) — no depende solo de la computadora del taller. Tamaño: chico-
    mediano.
25. **Modo básico sin internet** — que la app siga funcionando (aunque sea
    para consultar, no guardar) si se cae el WiFi del taller. Tamaño: grande
    (requiere repensar cómo se guardan los datos localmente).

---

### Ideas más chicas, sin numerar (quedaron fuera del top 25 pero valen la pena)
- Sistema de puntos/descuentos para clientes frecuentes.
- Bot de WhatsApp real vía Twilio para el negocio de diseño web de Luis
  (código ya escrito en `supabase/functions/whatsapp-bot`, pendiente decisión
  de pagar Twilio — ver punto 1, mismo bloqueo).
