# Queries de Mem0 — Gil Muffler / negocio de diseño web

5 búsquedas semánticas útiles sobre la memoria de Luis en Mem0
(`user_id='luis_gilmuffler'`), guardada por `scripts/mem0-extractor.sh`.

Para correr cualquiera desde la terminal:

```
claude -p "Usa search_memories (user_id='luis_gilmuffler') para buscar: '<query>'. Muéstrame los resultados tal cual." --allowedTools "mcp__mem0__search_memories" --permission-mode acceptEdits
```

## 1. ¿Qué se automatizó recientemente en el proyecto?
`"¿qué se automatizó recientemente en el proyecto Gil Muffler?"`
Sirve para recordar rápido qué workflows/cron ya existen sin tener que
revisar el repo completo. **Probada** — encontró el briefing diario, el
reporte de clientes inactivos, y la edge function.

## 2. ¿Qué tareas manuales siguen pendientes de automatizar?
`"tareas manuales pendientes de automatizar"`
Para no perder de vista los cuellos de botella (ej. contactar prospectos a
mano) cuando Luis tenga tiempo de atacarlos.

## 3. ¿Cómo va la adopción real de la app (facturas/clientes nuevos)?
`"métricas de facturas y clientes nuevos de Gil Muffler"`
Línea base de uso semana a semana, para notar si la adopción del taller
sube o se estanca.

## 4. ¿Qué preferencias de trabajo o feedback ha dado Luis?
`"cómo prefiere Luis que le expliquen cosas técnicas"`
Para que futuras sesiones (o el propio Luis) recuerden su estilo de
colaboración sin tener que repetirlo.

## 5. ¿Hubo algún incidente de seguridad (claves, tokens expuestos)?
`"incidentes de seguridad con claves o tokens expuestos"`
**Probada** — confirmó (correctamente) que no hay ninguna memoria
guardada sobre esto todavía. Útil como chequeo rápido antes de tocar
producción.
