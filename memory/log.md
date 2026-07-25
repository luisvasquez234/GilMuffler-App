# Registro de corridas — automatizaciones de GilMuffler-App

Log de las corridas reales de los crons de este repo. No se edita a mano en cada
corrida — sirve como evidencia de que las automatizaciones sí corren y sí
producen resultado real (Sesión 8 de Academia Catalizadora, requisito de
"registro de ejecución").

## briefing-diario.yml (prospectos + adopción de la app)

| Fecha (UTC) | Resultado | Duración | Nota |
|---|---|---|---|
| 2026-07-25 01:09 | ❌ failure | 15s | primeros intentos, fallo de configuración inicial |
| 2026-07-25 01:16 | ❌ failure | 45s | |
| 2026-07-25 01:18 | ❌ failure | 31s | |
| 2026-07-25 01:21 | ✅ success | 3m52s | primera corrida verde |
| 2026-07-25 02:43 | ✅ success | 10m29s | corrida con integración de Supabase MCP |

## mem0-nightly.yml (extractor nocturno de memoria)

| Fecha (UTC) | Resultado | Duración | Nota |
|---|---|---|---|
| 2026-07-25 03:17 | ✅ success | 1m37s | primera corrida verde |
| 2026-07-25 10:53 | ❌ failure | 13s | exit 141 (SIGPIPE) en `git log \| head -10` bajo `pipefail` |
| 2026-07-25 20:47 | ✅ success | 1m12s | corregido: `git log -n 10` sin pipe (ver commit `3220f04`) |

## orquesta.yml (repo separado `mis-agentes`, Sesión 7)

| Fecha (UTC) | Resultado | Duración | Nota |
|---|---|---|---|
| 2026-07-25 20:36 | ✅ success | 38s | primera corrida verde, 3 subagentes en paralelo |
