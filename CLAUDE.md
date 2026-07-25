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
