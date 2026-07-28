import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, init: ResponseInit = {}): Response {
  return Response.json(body, { ...init, headers: { ...CORS_HEADERS, ...(init.headers || {}) } });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  const { email, password, nombre } = await req.json();
  if (!email || !password || !nombre) {
    return json({ error: "Falta email, password o nombre" }, { status: 400 });
  }
  if (String(password).length < 6) {
    return json({ error: "La contraseña debe tener al menos 6 caracteres" }, { status: 400 });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });

  if (createError || !created.user) {
    return json({ error: createError?.message || "No se pudo crear el usuario" }, { status: 400 });
  }

  const { error: profileError } = await admin.from("empleados").insert({
    id: created.user.id,
    nombre,
    email,
  });

  if (profileError) {
    return json({ error: "Usuario creado pero falló el perfil: " + profileError.message }, { status: 500 });
  }

  return json({ created: true, id: created.user.id });
});
