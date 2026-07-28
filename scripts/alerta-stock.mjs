// Alerta de piezas con poco stock: revisa la tabla piezas y manda un email
// con las que ya llegaron a su stock mínimo (o menos).
// Corre desde .github/workflows/alerta-stock.yml (cron diario).

const SUPABASE_URL = "https://tussmuklnvqwkbdcjwtq.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_OTwDiyrfqcVssGLIc0YV1g_voNCq_IC";
const CRON_EMAIL = process.env.GILMUFFLER_CRON_EMAIL;
const CRON_PASSWORD = process.env.GILMUFFLER_CRON_PASSWORD;
const RESEND_API_KEY = process.env.RESEND_API_KEY;
const DESTINATARIO = "gilmuffler@hotmail.com";
const FROM_EMAIL = "Gil's Muffler <facturas@gilmuffler.shop>";

async function iniciarSesion() {
  const res = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: { apikey: SUPABASE_ANON_KEY, "Content-Type": "application/json" },
    body: JSON.stringify({ email: CRON_EMAIL, password: CRON_PASSWORD }),
  });
  if (!res.ok) throw new Error(`Fallo al iniciar sesión: ${res.status} ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

async function fetchPiezasBajoStock(accessToken) {
  const url = `${SUPABASE_URL}/rest/v1/piezas?select=nombre,sku,stock,stock_minimo`;
  const res = await fetch(url, {
    headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) throw new Error(`Fallo al leer piezas: ${res.status} ${await res.text()}`);
  const piezas = await res.json();
  return piezas.filter((p) => Number(p.stock) <= Number(p.stock_minimo));
}

async function main() {
  const accessToken = await iniciarSesion();
  const piezas = await fetchPiezasBajoStock(accessToken);

  console.log(`${piezas.length} pieza(s) con poco stock`);
  if (!piezas.length) return;

  const filas = piezas
    .map(
      (p) =>
        `<tr><td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;">${p.nombre}</td>` +
        `<td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;">${p.sku || "—"}</td>` +
        `<td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;text-align:right;">${p.stock}</td>` +
        `<td style="padding:6px 8px;border-bottom:1px solid #e5e5e5;text-align:right;">${p.stock_minimo}</td></tr>`
    )
    .join("");

  const html = `
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;color:#1c2027;">
      <h2>Piezas con poco stock</h2>
      <p>Estas piezas ya llegaron a su stock mínimo (o menos):</p>
      <table style="width:100%;border-collapse:collapse;font-size:14px;">
        <thead>
          <tr style="background:#f4f5f7;">
            <th style="padding:6px 8px;text-align:left;">Pieza</th>
            <th style="padding:6px 8px;text-align:left;">SKU</th>
            <th style="padding:6px 8px;text-align:right;">Stock</th>
            <th style="padding:6px 8px;text-align:right;">Mínimo</th>
          </tr>
        </thead>
        <tbody>${filas}</tbody>
      </table>
    </div>
  `;

  const resp = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: DESTINATARIO,
      subject: `${piezas.length} pieza(s) con poco stock — Gil's Muffler`,
      html,
    }),
  });

  if (!resp.ok) {
    throw new Error(`Fallo al enviar el email de alerta: ${resp.status} ${await resp.text()}`);
  }
  console.log("Alerta enviada a", DESTINATARIO);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
