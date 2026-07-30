// Servidor MCP (Model Context Protocol) de Gil Muffler.
// Sin verificación JWT de Supabase (un cliente MCP no hace login normal), pero
// exige una clave secreta compartida en el header Authorization — ver
// MCP_SHARED_SECRET más abajo. Sin esa clave, cualquier request se rechaza
// antes de tocar la base de datos.
// Conexión: `claude mcp add --transport http gilmuffler <url> --header
// "Authorization: Bearer <secret>"`. Implementa el transporte "Streamable
// HTTP": el cliente manda un POST con un mensaje JSON-RPC 2.0 y este handler
// responde con un único objeto JSON (sin abrir stream SSE, ya que no hace
// falta para estas herramientas).
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const MCP_SHARED_SECRET = Deno.env.get("MCP_SHARED_SECRET")!;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

function autorizado(req: Request): boolean {
  const header = req.headers.get("Authorization") ?? "";
  const recibido = header.startsWith("Bearer ") ? header.slice(7) : "";
  if (!MCP_SHARED_SECRET || recibido.length !== MCP_SHARED_SECRET.length) return false;
  let diff = 0;
  for (let i = 0; i < recibido.length; i++) {
    diff |= recibido.charCodeAt(i) ^ MCP_SHARED_SECRET.charCodeAt(i);
  }
  return diff === 0;
}

const PROTOCOL_VERSION = "2025-06-18";

const TOOLS = [
  {
    name: "facturas_pendientes",
    description:
      "Lista las facturas de Gil's Muffler en estado 'pendiente' (sin pagar), con cliente, total y fecha.",
    inputSchema: { type: "object", properties: {}, additionalProperties: false },
  },
  {
    name: "buscar_cliente",
    description:
      "Busca clientes de Gil's Muffler por nombre (o parte del nombre) y devuelve su teléfono y vehículo registrado.",
    inputSchema: {
      type: "object",
      properties: {
        nombre: { type: "string", description: "Nombre o parte del nombre del cliente a buscar" },
      },
      required: ["nombre"],
      additionalProperties: false,
    },
  },
  {
    name: "piezas_bajo_stock",
    description:
      "Lista las piezas del inventario cuyo stock actual está en o por debajo del stock mínimo configurado (candidatas a reordenar).",
    inputSchema: { type: "object", properties: {}, additionalProperties: false },
  },
];

async function facturasPendientes(): Promise<string> {
  const { data, error } = await supabase
    .from("facturas")
    .select("numero, fecha, total, clientes(nombre)")
    .eq("estado", "pendiente")
    .order("fecha", { ascending: true });

  if (error) throw new Error(error.message);
  if (!data || data.length === 0) return "No hay facturas pendientes en este momento.";

  const lineas = data.map((f: Record<string, unknown>) => {
    const cliente = (f.clientes as { nombre?: string } | null)?.nombre ?? "cliente desconocido";
    return `#${f.numero} — ${cliente} — $${f.total} — ${f.fecha}`;
  });
  return `Facturas pendientes (${data.length}):\n${lineas.join("\n")}`;
}

async function buscarCliente(nombre: string): Promise<string> {
  const { data, error } = await supabase
    .from("clientes")
    .select("nombre, telefono, vehiculo_marca, vehiculo_modelo, vehiculo_placa")
    .ilike("nombre", `%${nombre}%`)
    .order("nombre")
    .limit(10);

  if (error) throw new Error(error.message);
  if (!data || data.length === 0) return `No se encontró ningún cliente con nombre que contenga "${nombre}".`;

  const lineas = data.map((c: Record<string, unknown>) => {
    const vehiculo = [c.vehiculo_marca, c.vehiculo_modelo].filter(Boolean).join(" ") || "sin vehículo registrado";
    const placa = c.vehiculo_placa ? ` (placa ${c.vehiculo_placa})` : "";
    return `${c.nombre} — tel: ${c.telefono ?? "sin teléfono"} — ${vehiculo}${placa}`;
  });
  return `Clientes encontrados (${data.length}):\n${lineas.join("\n")}`;
}

async function piezasBajoStock(): Promise<string> {
  const { data, error } = await supabase
    .from("piezas")
    .select("nombre, sku, stock, stock_minimo, proveedor")
    .order("nombre");

  if (error) throw new Error(error.message);

  const bajas = (data ?? []).filter((p: Record<string, unknown>) => Number(p.stock) <= Number(p.stock_minimo));
  if (bajas.length === 0) return "Ninguna pieza está por debajo de su stock mínimo.";

  const lineas = bajas.map((p: Record<string, unknown>) => {
    const sku = p.sku ? ` (SKU ${p.sku})` : "";
    const proveedor = p.proveedor ? ` — proveedor: ${p.proveedor}` : "";
    return `${p.nombre}${sku} — stock: ${p.stock}/${p.stock_minimo}${proveedor}`;
  });
  return `Piezas por debajo del stock mínimo (${bajas.length}):\n${lineas.join("\n")}`;
}

function rpcResult(id: unknown, result: unknown) {
  return { jsonrpc: "2.0", id, result };
}
function rpcError(id: unknown, code: number, message: string) {
  return { jsonrpc: "2.0", id, error: { code, message } };
}

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers": "content-type, mcp-session-id, mcp-protocol-version, authorization",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });

  if (!autorizado(req)) {
    return Response.json({ error: "No autorizado" }, { status: 401, headers: CORS_HEADERS });
  }

  if (req.method !== "POST") {
    return new Response(
      'Servidor MCP de Gil Muffler. Conéctate con: claude mcp add --transport http gilmuffler <esta-url> --header "Authorization: Bearer <secret>"',
      { headers: { ...CORS_HEADERS, "Content-Type": "text/plain" } },
    );
  }

  let message: {
    id?: unknown;
    method?: string;
    params?: { name?: string; arguments?: { nombre?: string } };
  };
  try {
    message = await req.json();
  } catch {
    return Response.json(rpcError(null, -32700, "Parse error"), { status: 400, headers: CORS_HEADERS });
  }

  const { id, method, params } = message;

  // Notificaciones (sin id, ej. notifications/initialized) no llevan respuesta.
  if (id === undefined) return new Response(null, { status: 202, headers: CORS_HEADERS });

  try {
    switch (method) {
      case "initialize":
        return Response.json(
          rpcResult(id, {
            protocolVersion: PROTOCOL_VERSION,
            capabilities: { tools: {} },
            serverInfo: { name: "gilmuffler-mcp", version: "1.0.0" },
          }),
          { headers: CORS_HEADERS },
        );

      case "ping":
        return Response.json(rpcResult(id, {}), { headers: CORS_HEADERS });

      case "tools/list":
        return Response.json(rpcResult(id, { tools: TOOLS }), { headers: CORS_HEADERS });

      case "tools/call": {
        const args = params?.arguments;
        let text: string;
        switch (params?.name) {
          case "facturas_pendientes":
            text = await facturasPendientes();
            break;
          case "buscar_cliente":
            text = await buscarCliente(args?.nombre ?? "");
            break;
          case "piezas_bajo_stock":
            text = await piezasBajoStock();
            break;
          default:
            return Response.json(rpcError(id, -32602, `Herramienta desconocida: ${params?.name}`), {
              headers: CORS_HEADERS,
            });
        }
        return Response.json(rpcResult(id, { content: [{ type: "text", text }] }), { headers: CORS_HEADERS });
      }

      default:
        return Response.json(rpcError(id, -32601, `Método no soportado: ${method}`), { headers: CORS_HEADERS });
    }
  } catch (err) {
    return Response.json(rpcError(id, -32000, err instanceof Error ? err.message : "Error interno"), {
      status: 500,
      headers: CORS_HEADERS,
    });
  }
});
