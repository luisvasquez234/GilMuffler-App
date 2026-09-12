// Recordatorio automático de mantenimiento: cada vehículo que lleve 6 meses
// o 5,000 millas desde su última visita registrada (kilometraje_historial)
// recibe un email directo (no pasa por Luis, a diferencia de la alerta de
// stock bajo) invitándolo a traer el carro. Solo aplica a clientes con email
// guardado. No se repite todos los días: una vez enviado, se guarda la fecha
// en vehiculos.recordatorio_mantenimiento_enviado_en y no se vuelve a mandar
// hasta que haya una visita más reciente que esa fecha (o sea, hasta que el
// carro vuelva a estar vencido después de un servicio nuevo).
// Corre desde .github/workflows/recordatorio-mantenimiento.yml (cron diario).

const SUPABASE_URL = "https://tussmuklnvqwkbdcjwtq.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_OTwDiyrfqcVssGLIc0YV1g_voNCq_IC";
const CRON_EMAIL = process.env.GILMUFFLER_CRON_EMAIL;
const CRON_PASSWORD = process.env.GILMUFFLER_CRON_PASSWORD;
const RESEND_API_KEY = process.env.RESEND_API_KEY;
const FROM_EMAIL = "Gil's Muffler <facturas@gilmuffler.shop>";

const MESES_LIMITE = 6;
const MILLAS_LIMITE = 5000;

function escapeHtml(s) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

function soloNumero(texto) {
  if (texto == null) return null;
  const limpio = String(texto).replace(/[^\d.]/g, "");
  const n = parseFloat(limpio);
  return Number.isFinite(n) ? n : null;
}

function mesesEntre(fechaIso, hoyIso) {
  const a = new Date(fechaIso + "T00:00:00");
  const b = new Date(hoyIso + "T00:00:00");
  return (b.getFullYear() - a.getFullYear()) * 12 + (b.getMonth() - a.getMonth()) - (b.getDate() < a.getDate() ? 1 : 0);
}

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

async function fetchJson(path, accessToken) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) throw new Error(`Fallo al leer ${path}: ${res.status} ${await res.text()}`);
  return res.json();
}

async function actualizarVehiculo(id, payload, accessToken) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/vehiculos?id=eq.${id}`, {
    method: "PATCH",
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
      Prefer: "return=minimal",
    },
    body: JSON.stringify(payload),
  });
  if (!res.ok) throw new Error(`Fallo al actualizar vehiculo ${id}: ${res.status} ${await res.text()}`);
}

async function enviarEmail(cliente, vehiculo, nombreNegocio, colorAcento) {
  const clienteNombre = [cliente.nombre, cliente.apellido].filter(Boolean).join(" ") || "";
  const vehiculoLabel = [vehiculo.marca, vehiculo.modelo, vehiculo.anio].filter(Boolean).join(" ") || "tu vehículo";

  const html = `
    <div style="font-family:Arial,Helvetica,sans-serif;color:#1f2430;max-width:32rem;margin:0 auto;">
      <h2 style="color:${colorAcento};margin-bottom:.25rem;">${escapeHtml(nombreNegocio)}</h2>
      <p>Hola ${escapeHtml(clienteNombre)}, ya se acerca (o ya toca) el próximo mantenimiento de ${escapeHtml(vehiculoLabel)}.</p>
      <p>Recomendamos una revisión cada ${MESES_LIMITE} meses o ${MILLAS_LIMITE.toLocaleString("es")} millas, lo que llegue primero.</p>
      <p style="color:#68707e;font-size:.8rem;margin-top:1.5rem;">Si ya lo trajiste recientemente, ignora este mensaje. Gracias por tu confianza en ${escapeHtml(nombreNegocio)}.</p>
    </div>
  `;

  const resp = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: cliente.email,
      subject: `Ya se acerca el próximo servicio de ${vehiculoLabel} — ${nombreNegocio}`,
      html,
    }),
  });

  if (!resp.ok) throw new Error(`Fallo al enviar email a ${cliente.email}: ${resp.status} ${await resp.text()}`);
}

async function main() {
  const accessToken = await iniciarSesion();
  const hoy = new Date().toISOString().slice(0, 10);

  const [vehiculos, historial, cfgList] = await Promise.all([
    fetchJson("vehiculos?select=id,marca,modelo,anio,kilometraje,recordatorio_mantenimiento_enviado_en,clientes(nombre,apellido,email)", accessToken),
    fetchJson("kilometraje_historial?select=vehiculo_id,kilometraje,fecha&order=fecha.desc", accessToken),
    fetchJson("configuracion_negocio?select=nombre_negocio,color_acento&id=eq.1", accessToken),
  ]);

  const cfg = cfgList[0] || {};
  const nombreNegocio = cfg.nombre_negocio || "Gil's Muffler";
  const colorAcento = cfg.color_acento || "#d5601a";

  const ultimaVisitaPorVehiculo = new Map();
  for (const h of historial) {
    if (!ultimaVisitaPorVehiculo.has(h.vehiculo_id)) {
      ultimaVisitaPorVehiculo.set(h.vehiculo_id, h);
    }
  }

  let enviados = 0;
  for (const v of vehiculos) {
    const email = v.clientes && v.clientes.email;
    if (!email) continue;

    const ultimaVisita = ultimaVisitaPorVehiculo.get(v.id);
    if (!ultimaVisita) continue;

    const meses = mesesEntre(ultimaVisita.fecha, hoy);
    const kmUltimaVisita = soloNumero(ultimaVisita.kilometraje);
    const kmActual = soloNumero(v.kilometraje);
    const millasRecorridas = kmUltimaVisita != null && kmActual != null ? kmActual - kmUltimaVisita : 0;

    const vencido = meses >= MESES_LIMITE || millasRecorridas >= MILLAS_LIMITE;
    if (!vencido) continue;

    const yaEnviado = v.recordatorio_mantenimiento_enviado_en && v.recordatorio_mantenimiento_enviado_en >= ultimaVisita.fecha;
    if (yaEnviado) continue;

    await enviarEmail(v.clientes, v, nombreNegocio, colorAcento);
    await actualizarVehiculo(v.id, { recordatorio_mantenimiento_enviado_en: hoy }, accessToken);
    enviados++;
    console.log(`Recordatorio enviado a ${email} (vehículo ${v.id})`);
  }

  console.log(`${enviados} recordatorio(s) de mantenimiento enviado(s)`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
