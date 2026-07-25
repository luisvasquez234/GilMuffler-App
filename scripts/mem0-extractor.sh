#!/usr/bin/env bash
# Extractor nocturno de Mem0 para Luis (Gil Muffler / negocio de diseño web).
# Fuentes: (1) commits recientes de este repo, (2) datos reales de Supabase,
# (3) notas.txt manuales. Guarda hechos nuevos en Mem0 vía Claude Code.
set -euo pipefail

cd "$(dirname "$0")/.."

FECHA=$(date +%F)
NOTAS=$(cat notas.txt 2>/dev/null || echo "(sin notas.txt)")
COMMITS=$(git log --since="2 days ago" --pretty=format:"- %ad: %s" --date=short -n 10 2>/dev/null)
if [ -z "$COMMITS" ]; then
  COMMITS="(sin commits nuevos en los últimos 2 días)"
fi

MCP_CONFIG=$(mktemp)
cat > "$MCP_CONFIG" <<EOF
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest", "--project-ref=tussmuklnvqwkbdcjwtq"],
      "env": { "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN:-}" }
    },
    "mem0": {
      "type": "http",
      "url": "https://mcp.mem0.ai/mcp/",
      "headers": { "Authorization": "Bearer ${MEM0_API_KEY:-}" }
    }
  }
}
EOF

PROMPT="Eres el extractor nocturno de memoria de Luis (taller Gil Muffler en Lawrence, MA / su negocio de diseño web). Hoy es $FECHA.

Fuente 1 - Commits recientes del repo GilMuffler-App:
$COMMITS

Fuente 2 - Consulta esto en Supabase con execute_sql y reporta los números:
select
  (select count(*) from facturas where fecha >= current_date - interval '7 days') as facturas_ultima_semana,
  (select count(*) from clientes where created_at >= current_date - interval '7 days') as clientes_nuevos_ultima_semana;

Fuente 3 - Notas manuales de Luis (pueden estar vacías):
$NOTAS

Con estas 3 fuentes: guarda en Mem0 (usa add_memory, user_id='luis_gilmuffler', un hecho concreto por llamada) solo los hechos nuevos que valga la pena recordar a largo plazo — ignora fuentes vacías o sin nada relevante, no dupliques hechos obvios. Al final responde con una lista de cuántos hechos guardaste y cuáles fueron (en español, corta)."

set +e
RESPUESTA=$(claude -p "$PROMPT" --mcp-config "$MCP_CONFIG" --allowedTools "mcp__supabase__execute_sql,mcp__mem0__add_memory" --permission-mode acceptEdits 2>&1)
ESTADO=$?
set -e
rm -f "$MCP_CONFIG"

echo "$RESPUESTA"
exit $ESTADO
