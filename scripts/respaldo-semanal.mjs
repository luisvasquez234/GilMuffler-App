// Respaldo semanal de datos de Gil Muffler: exporta clientes, vehiculos,
// facturas, factura_items y ordenes_servicio a CSV y los manda por email.
// Corre desde .github/workflows/respaldo-semanal.yml (cron semanal).

const SUPABASE_URL = "https://tussmuklnvqwkbdcjwtq.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_OTwDiyrfqcVssGLIc0YV1g_voNCq_IC";
const RESEND_API_KEY = process.env.RESEND_API_KEY;
const DESTINATARIO = "gilmuffler@hotmail.com";
const FROM_EMAIL = "Gil's Muffler <facturas@gilmuffler.shop>";

const TABLAS = ["clientes", "vehiculos", "facturas", "factura_items", "ordenes_servicio"];

async function fetchTabla(nombre) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${nombre}?select=*`, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
    },
  });
  if (!res.ok) throw new Error(`Fallo al leer ${nombre}: ${res.status} ${await res.text()}`);
  return res.json();
}

function aCsv(filas) {
  if (!filas.length) return "";
  const columnas = Object.keys(filas[0]);
  const escapar = (v) => {
    if (v === null || v === undefined) return "";
    const s = String(v);
    return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
  };
  const lineas = [columnas.join(",")];
  for (const fila of filas) {
    lineas.push(columnas.map((c) => escapar(fila[c])).join(","));
  }
  return lineas.join("\n");
}

async function main() {
  const fecha = new Date().toISOString().slice(0, 10);
  const attachments = [];

  for (const tabla of TABLAS) {
    const filas = await fetchTabla(tabla);
    const csv = aCsv(filas) || "(sin filas)\n";
    console.log(`${tabla}: ${filas.length} filas`);
    attachments.push({
      filename: `${tabla}-${fecha}.csv`,
      content: Buffer.from(csv, "utf8").toString("base64"),
    });
  }

  const resp = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: DESTINATARIO,
      subject: `Respaldo semanal Gil Muffler — ${fecha}`,
      html: `<p>Respaldo automático del ${fecha}. Adjunto: ${TABLAS.join(", ")}.</p>`,
      attachments,
    }),
  });

  if (!resp.ok) {
    throw new Error(`Fallo al enviar el email de respaldo: ${resp.status} ${await resp.text()}`);
  }
  console.log("Respaldo enviado a", DESTINATARIO);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
