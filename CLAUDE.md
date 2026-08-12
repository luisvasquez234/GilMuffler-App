# Gil Muffler — App de gestión del taller

App de gestión para Gil's Muffler Inc (Lawrence, MA), reemplazando el sistema
de terceros AutoRepairBill. Cliente real: el propio taller donde Luis trabaja.

## Stack
- Frontend: HTML/CSS/JS plano (sin framework) — `index.html`, `app.js`, `styles.css`
- Backend: Supabase (base de datos + auth). Esquema en `schema*.sql`
  (usar siempre la versión más reciente, ej. `schema_v9.sql`, como referencia
  del estado actual — las versiones anteriores son historial, no borrar)
- Config: `config.js` es una PLANTILLA versionada en git (valores de ejemplo).
  `config.local.js` tiene las claves y contraseña reales y está en `.gitignore`
  — nunca poner valores reales en `config.js`.
- `ver-factura.html`: página pública para que el cliente vea su factura vía QR
  sin entrar al panel completo.

## Reglas del proyecto
- Luis no es programador de formación. Explica cambios técnicos en términos
  simples; si algo requiere tocar Supabase u otro dashboard externo, dale pasos
  numerados uno a la vez, confirmando que cada paso funcionó antes del siguiente.
- Nunca subas `config.local.js` ni ninguna clave/contraseña real a git.
- El taller opera con una sola contraseña compartida por ahora (`APP_PASSWORD`).
  No asumas login por usuario individual salvo que se implemente (ver
  `MEJORAS-PENDIENTES.md`, punto 21).
- `MEJORAS-PENDIENTES.md` es un menú de ideas, no un roadmap comprometido — no
  implementar nada de ahí sin que Luis lo pida explícitamente.
- Prioriza lo que destraba el uso diario del taller sobre mejoras "bonitas pero
  no urgentes" — el tiempo de Luis es limitado.

## Estilo de código
- Sin framework, sin build step. El frontend se mantiene en HTML/CSS/JS plano
  (`index.html`, `app.js`, `styles.css`, más las páginas públicas `ver-*.html`).
  No introducir React, bundlers, TypeScript, etc.
- Priorizar código simple y legible sobre código compacto/clever — Luis no es
  programador, así que la calidad se mide en "se puede explicar en términos
  simples", no en elegancia idiomática.
- Comentar solo el "por qué" no obvio (una rareza de Supabase, un gotcha de
  RLS, un workaround). Nunca comentar el "qué".
- Todo texto de cara al usuario pasa por `i18n.js`: HTML estático usa atributos
  `data-i18n`/`data-i18n-placeholder`/`data-i18n-title`/`data-i18n-aria-label`/
  `data-i18n-html`; strings construidos dinámicamente (toasts, confirms,
  templates de impresión, HTML armado en JS en las 4 páginas públicas) llaman
  `t("key")` directamente. Agregar claves nuevas a `I18N.es` y `I18N.en` en el
  mismo edit, manteniendo la cantidad de claves igual en ambos.
- Nunca hacer `content.replace(oldstring, newstring)` a ciegas sobre todo un
  archivo para cambios de texto masivos — el mismo literal puede estar anidado
  dentro de otro string distinto (ej. un `attr="..."` de HTML dentro de un
  template string de JS) y quedar mal. Después de cualquier replace masivo,
  grep para patrones rotos típicos (ej. `=t("` sin comillas) y revisar el diff.
- Ojo con shadowing de parámetros: algunos `.map((t) => ...)` usan `t` como
  variable del loop, lo cual tapa la función global `t()` de i18n en ese scope.
  Renombrar la variable antes de agregar un `t()` ahí.
- Cualquier string controlado por el usuario o que venga de la base de datos
  que vaya a `innerHTML` (o `<img src>`, `href`, etc.) debe pasar primero por
  `escapeHtml()` — esta app ya tuvo un bug de XSS ahí (`logo_url`).
- Los archivos `schema_vN.sql` son historial append-only. Siempre agregar una
  versión nueva numerada para un cambio de esquema; nunca editar ni borrar una
  vieja.

## Testing
- No hay suite de tests automatizados (sin Jest/Playwright de test, sin paso
  de tests en CI) — es intencional dado el stack y que Luis no es programador;
  no introducir un framework de testing sin que él lo pida.
- El smoke-test manual es la red de seguridad real. Usar el skill
  `run-gilmuffler-app` (server estático + Playwright-Python `driver.py`) para
  cargar la app de verdad y revisar errores de consola después de cualquier
  cambio, no solo mirar el diff.
- Cambios de seguridad/permisos (políticas RLS, checks de auth) hay que
  verificarlos empíricamente contra el sistema *desplegado en vivo* — fetch/curl
  real con la anon key, chequeando la respuesta real — no solo leyendo el
  historial de `schema_vN.sql`. Este repo ya tuvo bugs de RLS donde los
  archivos de migración decían una cosa y la base en vivo otra.
- Páginas públicas nuevas (o existentes que lean una tabla nueva) necesitan un
  check explícito de lectura con la anon key — una respuesta `200 []` vacía en
  silencio (no un `403`) es el modo de falla típico acá, así que "no tiró
  error" no es prueba de que funciona.
- Antes de shippear cambios no triviales, correr el skill `pre-deploy-check`
  (`/security-review` + `frontend-security-accessibility-reviewer`) como chequeo
  previo.
- Después de cualquier find/replace masivo en HTML/JS (claves de i18n,
  refactors), validar con grep/script en vez de confiar en el ojo — ej.
  confirmar que cada `t("key"` en app.js tiene su clave correspondiente en
  `I18N.es` y `I18N.en`.

## Flujo de trabajo
- Netlify se mantiene en "Stopped builds" por default — un push a GitHub NO
  debe auto-desplegar (esto ya vació el pool de créditos free-tier una vez).
  Para publicar de verdad: cambiar a "Active builds" → "Trigger deploy" →
  volver a "Stopped builds" apenas termine. Siempre volver a detenerlo, no
  dejarlo activo.
- Supabase no tiene CLI en esta máquina — los cambios de esquema/RLS/edge
  functions van por el dashboard web, paso a paso (ver skill
  `deploy-supabase-changes`). Al pegar SQL en el editor del dashboard, usar
  `pbcopy` con el contenido exacto del archivo (no hacer que Luis copie desde
  el chat — los caracteres de comillas se pueden romper) y confirmar que el
  editor esté completamente vacío antes de pegar código de función nuevo.
- Existen dos copias de este repo que deben mantenerse idénticas:
  `/Users/luis/Desktop/GIL MUFFLER PROJECTO/GilMuffler-App` y
  `/Users/luis/GIL MUFFLER PROJECTO/GilMuffler-App`. Si se edita una, replicar
  el mismo cambio en la otra (o confirmar con Luis cuál es la canónica en esa
  sesión).
- No tomar acciones en Netlify/Supabase que afecten la app real en producción
  sin el visto bueno de Luis — es una herramienta operativa real de un taller,
  no un sandbox.

## Pendiente de automatizar

- **Contactar prospectos encontrados por el briefing diario**: hoy en día,
  cuando `briefing.md` encuentra negocios sin buena web (via el cron de
  `.github/workflows/briefing-diario.yml`), Luis copia el contacto a mano y
  manda el mensaje generado por `/prospecto` uno por uno (WhatsApp/email).
  Cruza dos herramientas (el briefing/GitHub y el canal de contacto real) sin
  conexión automática entre ellas todavía. Candidato a automatizar más
  adelante (ej. que el propio cron genere también el mensaje de contacto, o
  se integre con WhatsApp/email directamente) — no implementar sin que Luis
  lo pida explícitamente.
