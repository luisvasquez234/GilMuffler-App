# Ideas para mejorar la app de Gil Muffler

Lista de mejoras posibles, para revisar y decidir cuáles implementar más
adelante. No es necesario hacerlas todas ni en este orden — es solo un menú
de opciones.

## Comunicación con clientes

1. Enviar la factura por email automáticamente al cliente al marcarla como pagada
2. Avisar por WhatsApp cuando el carro está listo para recoger
3. Recordatorio automático de mantenimiento (ej. "ya se acerca tu próximo cambio de aceite")
4. Enviar link para dejar reseña en Google después de facturar
5. Página pública donde el cliente ve el estado de su orden sin entrar al panel completo (parecido a la de `ver-factura.html` que ya existe)
6. Reporte de clientes que no han vuelto en X meses, para contactarlos

## Facturación y pagos

7. Botón de "pagar en línea" en la factura (Stripe o PayPal) para que el cliente pague sin ir al taller
8. Firma digital del cliente al recoger el vehículo, como comprobante de entrega
9. Presupuestos/estimados que el cliente aprueba en línea antes de autorizar el trabajo
10. Historial de precios de piezas (ver cuándo subió un proveedor)
11. Calculadora de garantía: avisar si una pieza instalada todavía está en garantía

## Vehículos y órdenes de servicio

12. Varios vehículos por cliente (ahora mismo cada cliente tiene un solo carro registrado)
13. Historial completo de kilometraje del vehículo a través del tiempo
14. Fotos antes/después adjuntas a la orden (evidencia del trabajo hecho)
15. Checklist de inspección por orden (frenos, luces, llantas, etc.)
16. Vista de calendario con las entregas estimadas de la semana

## Reportes y finanzas

17. Reporte de ganancias por tipo de servicio o pieza más vendida
18. Reporte de piezas más usadas / rotación de inventario
19. Exportar reporte de impuestos trimestral o anual para el contador
20. Alertas cuando una pieza tiene poco stock (por email o notificación)

## Usuarios y seguridad

21. Varios usuarios con su propio inicio de sesión (en vez de una sola contraseña compartida)
22. Registrar qué empleado hizo cada orden o factura
23. Calculadora de comisiones por empleado
24. Respaldo automático de los datos (exportar todo a Excel/PDF cada cierto tiempo)

## Programa de clientes frecuentes

25. Sistema de puntos o descuentos por lealtad para clientes frecuentes

## Técnico / infraestructura

26. Instalar la app como aplicación del celular (PWA), sin depender solo de la computadora del taller
27. Modo básico sin internet, para cuando se cae la conexión en el taller
28. Búsqueda global: un solo cuadro para buscar cliente, placa o factura, sin importar la sección
29. Publicar `ver-factura.html` en un hosting real (no solo la red local), para que el QR funcione desde cualquier lugar, no solo el WiFi del taller
30. Activar de verdad el bot de WhatsApp (`supabase/functions/whatsapp-bot`): el código ya está escrito y desplegado en Supabase, pero Twilio pide agregar tarjeta para configurar el Sandbox — pendiente de que Luis decida si vale la pena pagarlo o buscar otra vía (ej. email) para el canal de salida
