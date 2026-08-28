import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;

// Mismo remitente verificado que ya usa enviar-factura-email — no crear un
// segundo dominio/remitente para lo mismo.
const FROM_EMAIL = "Gil's Muffler <facturas@gilmuffler.shop>";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, init: ResponseInit = {}): Response {
  return Response.json(body, { ...init, headers: { ...CORS_HEADERS, ...(init.headers || {}) } });
}

function escapeHtml(s: unknown): string {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" } as Record<string, string>)[c]);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "No autorizado" }, { status: 401 });
  }
  const callerClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: callerData, error: callerError } = await callerClient.auth.getUser();
  if (callerError || !callerData.user) {
    return json({ error: "No autorizado" }, { status: 401 });
  }

  const { orden_id, orden_url } = await req.json();
  if (!orden_id) {
    return json({ error: "Falta orden_id" }, { status: 400 });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: orden, error: ordenError } = await admin
    .from("ordenes_servicio")
    .select("*, clientes(nombre, apellido, email)")
    .eq("id", orden_id)
    .maybeSingle();

  if (ordenError || !orden) {
    return json({ error: "No se encontró la orden" }, { status: 404 });
  }

  const clienteEmail = orden.clientes?.email;
  if (!clienteEmail) {
    // Sin email en el cliente: no es un error, simplemente no hay a dónde mandarlo.
    return json({ sent: false, reason: "sin_email" });
  }

  const { data: cfg } = await admin.from("configuracion_negocio").select("*").eq("id", 1).maybeSingle();
  const nombreNegocio = cfg?.nombre_negocio || "Gil's Muffler";
  const colorAcento = cfg?.color_acento || "#d5601a";
  const clienteNombre = [orden.clientes?.nombre, orden.clientes?.apellido].filter(Boolean).join(" ") || "";
  const numeroOrden = String(orden.numero).padStart(4, "0");
  const vehiculo = [orden.vehiculo_marca, orden.vehiculo_modelo, orden.vehiculo_anio].filter(Boolean).join(" ");
  const url = orden_url || "";

  const html = `
    <div style="font-family:Arial,Helvetica,sans-serif;color:#1f2430;max-width:32rem;margin:0 auto;">
      <h2 style="color:${colorAcento};margin-bottom:.25rem;">${escapeHtml(nombreNegocio)}</h2>
      <p>Hola ${escapeHtml(clienteNombre)}, tu orden #${numeroOrden}${vehiculo ? " (" + escapeHtml(vehiculo) + ")" : ""} ya está lista para recoger.</p>
      ${url ? `<p><a href="${escapeHtml(url)}" style="display:inline-block;padding:.6rem 1.2rem;background:${colorAcento};color:#fff;text-decoration:none;border-radius:8px;">Ver detalle</a></p>` : ""}
      <p style="color:#68707e;font-size:.8rem;margin-top:1.5rem;">Gracias por tu confianza en ${escapeHtml(nombreNegocio)}.</p>
    </div>
  `;

  const resp = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: clienteEmail,
      subject: `Tu carro ya está listo — orden #${numeroOrden}`,
      html,
    }),
  });

  if (!resp.ok) {
    const detalle = await resp.text();
    return json({ error: "No se pudo enviar el email: " + detalle }, { status: 502 });
  }

  return json({ sent: true });
});
