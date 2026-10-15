// Each shop's Netlify sets SUSPENDIDO=si when the shop stops paying. This runs before the app
// loads, swaps the page for a notice and stops the rest of the page's scripts. The shop's data
// in Supabase is untouched, so switching it back to "no" restores everything.
(function () {
  if (typeof CONFIG === "undefined") return;
  const valor = String(CONFIG.SUSPENDIDO || "").trim().toLowerCase();
  if (["si", "sí", "yes", "true"].indexOf(valor) === -1) return;

  window.APP_SUSPENDIDA = true;
  const tr = (clave, vars) => (typeof t === "function" ? t(clave, vars) : clave);
  const escapar = (s) => String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const contacto = String(CONFIG.CONTACTO_SUSPENSION || "").trim();
  // Default: Luis's PayPal monthly plan ($250/mo, same one as vender-programa.html).
  const PAGO_PAYPAL = "https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-2KT85050TT502193CNKIHWGY";
  const pagoUrl = String(CONFIG.PAGO_URL || PAGO_PAYPAL).trim();
  const pagoValido = /^https:\/\//i.test(pagoUrl);

  document.body.innerHTML =
    '<div style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:2rem;font-family:Arial,Helvetica,sans-serif;background:#f4f5f7;color:#1f2430;">' +
    '<div style="max-width:28rem;background:#fff;border-radius:12px;padding:2rem;box-shadow:0 4px 20px rgba(0,0,0,.08);text-align:center;">' +
    '<div style="font-size:2.5rem;margin-bottom:.5rem;">🔒</div>' +
    '<h1 style="font-size:1.4rem;margin:0 0 .75rem;">' + escapar(tr("suspendido_titulo")) + "</h1>" +
    '<p style="margin:0 0 .75rem;line-height:1.5;">' + escapar(tr("suspendido_mensaje")) + "</p>" +
    (pagoValido
      ? '<a href="' + escapar(pagoUrl) + '" target="_blank" rel="noopener" style="display:inline-block;margin:.5rem 0 1rem;padding:.8rem 1.6rem;background:#16a34a;color:#fff;border-radius:8px;font-weight:bold;text-decoration:none;font-size:1.05rem;">' + escapar(tr("suspendido_pagar")) + "</a>"
      : "") +
    (contacto ? '<p style="margin:0;font-weight:bold;">' + escapar(tr("suspendido_contacto", { contacto: contacto })) + "</p>" : "") +
    "</div></div>";
  window.stop();
})();
