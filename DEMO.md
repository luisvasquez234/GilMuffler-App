# DEMO — Mi OpenClaw (Sesión 8, Academia Catalizadora)

**Video:** https://drive.google.com/file/d/1exiXYgqoAKcUVT67jRRh0WrtaUm1mm-1/view?usp=drive_link

Guion para grabar. No hace falta memorizarlo palabra por palabra — es una guía
para no perder el hilo. Practica una vez antes de grabar.

## 1. El problema (2 min)

- Trabajo en el negocio de mufflers de mi familia (Gil's Muffler Inc, Lawrence, MA),
  pero mi meta es dedicarme 100% al diseño web.
- Le construí a Gil Muffler una app de gestión real, de la nada, para reemplazar
  un software de terceros (AutoRepairBill) — esa app es mi prueba social como
  diseñador web.
- Lo que más tiempo me quita hoy: conseguir clientes nuevos para mi negocio de
  diseño web. Buscar prospectos, ver quién no tiene buena página, y dar
  seguimiento — todo a mano.

## 2. Sistema en vivo, con datos reales (3 min)

Mostrar en pantalla, en este orden:

1. `CLAUDE.md` del repo GilMuffler-App — mi memoria persistente: describe el
   negocio real, no un ejemplo de juguete.
2. Correr (o mostrar la última corrida verde en Actions) `briefing-diario.yml`
   — encuentra negocios reales de Lawrence/Methuen/Andover sin buena web, y
   cruza con datos reales de Supabase (clientes inactivos de Gil Muffler).
3. Mostrar `memory/log.md` — evidencia de que estas corridas son reales, con
   fecha y resultado, no una demo de mentiras.
4. Mostrar una búsqueda en Mem0 (`ver_mi_progreso` o una memoria guardada) —
   la IA recuerda cosas de mí entre sesiones sin que se las repita.
5. (Opcional si ya está activo) Mandar un mensaje real de WhatsApp al bot y
   mostrar la respuesta.

## 3. Arquitectura — las 4 piezas (2 min)

- **Memoria**: `CLAUDE.md` (contexto fijo del proyecto) + Mem0 (hechos que se
  acumulan solos cada noche, vía `mem0-nightly.yml`).
- **Herramientas**: MCP de Supabase (datos reales del taller) + edge functions
  (`mi-herramienta`, `whatsapp-bot`) — nada de datos de ejemplo.
- **Automatización**: 3 crons de GitHub Actions corriendo verdes — 2 en este
  repo (`briefing-diario.yml`, `mem0-nightly.yml`) y 1 en mi otro repo
  `mis-agentes` (`orquesta.yml`, un orquestador de 3 subagentes en paralelo).
- **Canal de salida**: bot de WhatsApp (Twilio + Claude + Mem0) — código
  escrito y desplegado en Supabase; conectarlo a un número real de Twilio
  quedó pendiente porque pide método de pago para el Sandbox. Lo explico como
  parte honesta del "qué sigue", no lo escondo.

## 4. Qué sigue (1 min)

- Activar el canal de salida real (Twilio con tarjeta, o cambiar a email como
  alternativa gratis).
- Conectar el briefing diario de prospectos con el envío del mensaje de
  contacto (`/prospecto`) — hoy todavía copio y pego a mano.
- Hábito post-academia: revisar Mem0 cada semana, auditar los crons cada mes,
  construir un agente nuevo cada trimestre.
