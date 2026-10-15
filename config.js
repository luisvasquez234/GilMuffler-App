// Configuración del panel. Estos tres valores son los únicos que hay que
// cambiar para poner la app a funcionar con tu propio proyecto de Supabase.
//
// Este archivo es una PLANTILLA (sí se sube a git). Los valores reales van
// en config.local.js, que está en .gitignore y nunca se sube.

const CONFIG = {
  SUPABASE_URL: "https://tu-proyecto.supabase.co",
  SUPABASE_ANON_KEY: "tu-anon-key-aqui",

  // Clave compartida temporal para entrar al panel (paso 1, mientras no hay
  // usuarios individuales). Cámbiala por la que quieras usar en el taller.
  APP_PASSWORD: "cambia-esta-clave",

  // "si" bloquea la app con un aviso de cuenta suspendida (falta de pago). Los
  // datos no se borran; con "no" todo vuelve a funcionar.
  SUSPENDIDO: "no",
  // Teléfono o correo que aparece en el aviso de cuenta suspendida.
  CONTACTO_SUSPENSION: "",
  // Enlace de pago (ej. un "Payment Link" de Stripe). Si está, el aviso muestra
  // un botón "Pagar ahora". Debe empezar con https://
  PAGO_URL: "",
};
