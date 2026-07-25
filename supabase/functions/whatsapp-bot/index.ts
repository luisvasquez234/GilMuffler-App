// Bot de WhatsApp para el negocio de diseño web de Luis.
// Recibe el webhook de Twilio, busca contexto en Mem0, llama a Claude,
// guarda la conversación en Mem0, y responde en formato TwiML.

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const MEM0_API_KEY = Deno.env.get("MEM0_API_KEY")!;

const SYSTEM_PROMPT = `Eres el asistente de WhatsApp de Luis, quien ofrece
servicios de diseño web para negocios locales en Lawrence, MA y alrededores.
Tu prueba social principal: Luis le construyó una app de gestión completa a
Gil's Muffler Inc, un taller de mufflers real en Lawrence, que reemplazó su
sistema viejo (AutoRepairBill) por uno hecho a su medida.

Responde en español, tono directo y honesto, sin relleno de agencia
("soluciones a la medida", "el siguiente nivel"). Sé breve (2-4 frases).`;

const HANDOFF_TRIGGERS = ["precio", "cuanto cuesta", "cuánto cuesta", "agendar", "cita", "no entiendo"];

function triggersHandoff(text: string): boolean {
  const lower = text.toLowerCase();
  return HANDOFF_TRIGGERS.some((t) => lower.includes(t));
}

async function getUserMemories(userId: string, query: string): Promise<string> {
  try {
    const res = await fetch("https://api.mem0.ai/v1/memories/search/", {
      method: "POST",
      headers: {
        "Authorization": `Token ${MEM0_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ query, user_id: userId, limit: 5 }),
    });
    if (!res.ok) return "";
    const data = await res.json();
    const memories = Array.isArray(data) ? data : [];
    return memories.map((m: { memory?: string }) => `- ${m.memory ?? ""}`).join("\n");
  } catch {
    return "";
  }
}

async function saveMemory(userId: string, text: string): Promise<void> {
  try {
    await fetch("https://api.mem0.ai/v1/memories/", {
      method: "POST",
      headers: {
        "Authorization": `Token ${MEM0_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ messages: [{ role: "user", content: text }], user_id: userId }),
    });
  } catch {
    // no bloquear la respuesta al usuario si Mem0 falla
  }
}

async function askClaude(userMessage: string, memories: string, handoff: boolean): Promise<string> {
  const context = memories
    ? `Esto es lo que recuerdas de conversaciones anteriores con este contacto:\n${memories}\n\n`
    : "";
  const handoffNote = handoff
    ? "\n\nEste mensaje activó una señal de handoff (precio/agendar/confusión) — dile que Luis le va a escribir directamente muy pronto."
    : "";

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-sonnet-5",
      max_tokens: 300,
      system: SYSTEM_PROMPT + handoffNote,
      messages: [{ role: "user", content: `${context}Mensaje de WhatsApp: ${userMessage}` }],
    }),
  });

  if (!res.ok) {
    console.error(`Anthropic API error ${res.status}: ${await res.text()}`);
    return "Disculpa, tuve un problema respondiendo. Luis te va a contactar directamente.";
  }
  const data = await res.json();
  const textBlock = (data.content ?? []).find((b: { type: string }) => b.type === "text");
  return textBlock?.text ?? "Gracias por tu mensaje, en un momento te respondemos.";
}

function twimlResponse(message: string): Response {
  const escaped = message
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
  const xml = `<?xml version="1.0" encoding="UTF-8"?><Response><Message>${escaped}</Message></Response>`;
  return new Response(xml, { headers: { "Content-Type": "text/xml" } });
}

Deno.serve(async (req: Request) => {
  const form = await req.formData();
  const from = String(form.get("From") ?? "desconocido");
  const body = String(form.get("Body") ?? "").trim();

  if (!body) {
    return twimlResponse("No recibí ningún mensaje, ¿puedes escribirlo de nuevo?");
  }

  const handoff = triggersHandoff(body);
  const memories = await getUserMemories(from, body);
  const reply = await askClaude(body, memories, handoff);

  await saveMemory(from, `Cliente (${from}) escribió: "${body}". Bot respondió: "${reply}".`);

  return twimlResponse(reply);
});
