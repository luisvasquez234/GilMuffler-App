import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FROM_EMAIL = "Gil's Muffler <facturas@gilmuffler.shop>";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, init: ResponseInit = {}): Response {
  return Response.json(body, { ...init, headers: { ...CORS_HEADERS, ...(init.headers || {}) } });
}

function money(n: number | null | undefined): string {
  return "$" + Number(n || 0).toFixed(2);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  const { factura_id } = await req.json();
  if (!factura_id) {
    return json({ error: "Falta factura_id" }, { status: 400 });
  }

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: factura, error: facturaError } = await supabase
    .from("facturas")
    .select("id, fecha, subtotal, impuesto, total, clientes(nombre, email)")
    .eq("id", factura_id)
    .single();

  if (facturaError || !factura) {
    return json({ error: "Factura no encontrada" }, { status: 404 });
  }

  const cliente = Array.isArray(factura.clientes) ? factura.clientes[0] : factura.clientes;
  if (!cliente?.email) {
    return json({ skipped: true, reason: "El cliente no tiene email registrado" });
  }

  const { data: items } = await supabase
    .from("factura_items")
    .select("descripcion, cantidad, precio_unitario, subtotal")
    .eq("factura_id", factura_id);

  const { data: negocio } = await supabase
    .from("configuracion_negocio")
    .select("nombre_negocio, direccion, telefono, mensaje_pie")
    .eq("id", 1)
    .single();

  const nombreNegocio = negocio?.nombre_negocio || "Gil's Muffler";

  const filasItems = (items || [])
    .map(
      (it) =>
        `<tr><td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;">${it.descripcion}</td>` +
        `<td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;text-align:center;">${it.cantidad}</td>` +
        `<td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;text-align:right;">${money(it.precio_unitario)}</td>` +
        `<td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;text-align:right;">${money(it.subtotal)}</td></tr>`
    )
    .join("");

  const html = `
    <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;color:#1c2027;">
      <h2 style="margin-bottom:4px;">${nombreNegocio}</h2>
      <p style="color:#5b6472;margin-top:0;">${negocio?.direccion || ""}${negocio?.telefono ? " · " + negocio.telefono : ""}</p>
      <p>Hola ${cliente.nombre || ""},</p>
      <p>Gracias por tu pago. Aquí está el resumen de tu factura:</p>
      <table style="width:100%;border-collapse:collapse;font-size:14px;">
        <thead>
          <tr style="background:#f4f5f7;">
            <th style="padding:6px 8px;text-align:left;">Servicio/Pieza</th>
            <th style="padding:6px 8px;">Cant.</th>
            <th style="padding:6px 8px;text-align:right;">Precio</th>
            <th style="padding:6px 8px;text-align:right;">Subtotal</th>
          </tr>
        </thead>
        <tbody>${filasItems}</tbody>
      </table>
      <p style="text-align:right;margin-top:12px;">
        Subtotal: ${money(factura.subtotal)}<br/>
        Impuesto: ${money(factura.impuesto)}<br/>
        <strong style="font-size:16px;">Total pagado: ${money(factura.total)}</strong>
      </p>
      <p style="color:#5b6472;font-size:13px;margin-top:24px;">${negocio?.mensaje_pie || "¡Gracias por tu preferencia!"}</p>
    </div>
  `;

  const resendResp = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: cliente.email,
      subject: `Tu factura de ${nombreNegocio} — ${money(factura.total)} pagado`,
      html,
    }),
  });

  if (!resendResp.ok) {
    const errText = await resendResp.text();
    console.error(`Resend error ${resendResp.status}: ${errText}`);
    return json({ error: "Fallo al enviar email", detail: errText }, { status: 500 });
  }

  return json({ sent: true });
});
