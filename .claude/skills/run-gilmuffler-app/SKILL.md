---
name: run-gilmuffler-app
description: Run, launch, start, or screenshot the GilMuffler-App shop-management web app (plain HTML/CSS/JS + Supabase) — serves it locally and drives it headlessly with the Playwright-Python REPL in driver.py to prove login/error states render.
---

Static frontend (`index.html` / `app.js` / `styles.css`, no build step) backed by Supabase (real project, keys in `config.local.js`). Driven via `.claude/skills/run-gilmuffler-app/driver.py`, a small Playwright-for-Python REPL (chromium-cli isn't installed on this machine and there's no node/npm to get it, so this replaces it — same verb set: `nav`/`click`/`fill`/`press`/`wait-for`/`screenshot`/`console`/`eval`).

All paths below are relative to the project root: `GilMuffler-App/`.

## Prerequisites

```bash
pip3 install playwright
python3 -m playwright install chromium
```

(Already installed on this machine as of 2026-07-30. On a fresh machine, run both lines first — the browser download is ~280MB.)

## Build

None — static files, served as-is.

## Run (agent path)

1. Start the static server in the background and wait for it to actually respond:

```bash
lsof -ti:8080 -sTCP:LISTEN | xargs -r kill 2>/dev/null   # free the port if a stale server is up
nohup python3 -m http.server 8080 > /tmp/gilmuffler-server.log 2>&1 & disown
for i in $(seq 1 15); do curl -sf http://localhost:8080/index.html >/dev/null 2>&1 && echo "SERVER UP" && break; sleep 0.5; done
```

2. Pipe commands to `driver.py` (verified working end-to-end on 2026-07-30):

```bash
python3 .claude/skills/run-gilmuffler-app/driver.py <<'EOF'
nav http://localhost:8080
wait-for text=Panel interno
screenshot login
fill #login-email nobody@example.com
fill #login-password wrongpass
click #login-form button[type=submit]
wait-for text=incorrectos
screenshot login-error
console --errors
quit
EOF
```

Screenshots land in `.claude/skills/run-gilmuffler-app/screenshots/<name>.png` (this proves the login form renders and that a wrong-credential submit produces the expected "Email o contraseña incorrectos." error via real Supabase Auth — `401`/`400` console errors at that point are expected, not a bug).

There are no test employee credentials available to this agent, so a real logged-in dashboard screenshot isn't possible from here — the login + error-state flow above is the representative interaction. If you get real credentials (or a Supabase magic-link/service-role workaround), extend the same heredoc with `wait-for #app-shell` (or whatever the post-login container is) and another `screenshot`.

**The 5 public pages need no login at all** (`llamame.html`, `ver-factura.html`, `ver-orden.html`, `ver-estimado.html`, `reportar-trabajo.html`) — they're customer-facing links opened via QR codes, so they're the one part of this app you *can* drive end-to-end for real, including console-error checks after any change to shared code (`i18n.js`, `styles.css`, `app.js` helpers these pages also load). Verified working (2026-08-18):

```bash
python3 .claude/skills/run-gilmuffler-app/driver.py <<'EOF'
nav http://localhost:8080/llamame.html
wait-for #telefono
fill #telefono 9785551234
eval document.getElementById('telefono').value
screenshot llamame-publica
console --errors
nav http://localhost:8080/ver-factura.html?id=00000000-0000-0000-0000-000000000000
wait-for text=No se encontró
screenshot ver-factura-not-found
console --errors
quit
EOF
```
`eval` returns `(978) 555-1234` (confirms a JS input-formatting feature actually ran, not just that the page loaded) and the invalid-id nav confirms the "record not found" UI renders instead of a blank page. A quick `nav` + `wait-for text=Panel interno` + `console --errors` round-trip on `index.html` itself is also a fast way to catch a JS syntax error introduced anywhere in `app.js`/`i18n.js`, since a parse error there breaks the whole page before login is ever reached.

3. Stop the server when done:

```bash
lsof -ti:8080 -sTCP:LISTEN | xargs -r kill
```

## Run (human path)

After step 1 above, open `http://localhost:8080` in a real browser on this Mac. `config.local.js` already has real Supabase keys, so it talks to the live shop database — log in with a real employee email/password.

`Iniciar-Gil-Muffler.bat` and `serve.ps1` in the project root are Windows-only leftovers (`.bat`/PowerShell) — they don't run on this Mac; the `python3 -m http.server` command above is the mac-appropriate equivalent.

## Gotchas

- **No node/npm/chromium-cli on this machine.** `which node|npx|brew` all fail. Don't reach for the usual `chromium-cli` web-app pattern — use `driver.py` (Python Playwright) instead.
- **Login is real Supabase Auth** (`sb.auth.signInWithPassword`, `app.js:559-564`), not the `APP_PASSWORD` string in `config.local.js` — that shared password is a separate/older gate referenced in `CLAUDE.md`, not what the visible login form checks. Don't expect `APP_PASSWORD` to work in the email/password fields.
- **Page title updates asynchronously.** It renders as generic "Gil Muffler" first, then swaps to "Gil's Muffler Inc" once branding loads from the `configuracion_negocio` Supabase table (visible between the two screenshots above) — that's normal, not a race bug.
- **Port 8080 collision**: if a previous run's server is still bound, `curl` polling above will still succeed against the *old* process serving stale files — always run the `lsof -ti:8080 ... kill` line first, not just when it fails.
- **`eval` takes a raw JS expression, not a shell-quoted arg.** Every other command line gets `shlex.split()`'d, which strips matching quote characters *anywhere* in the line, not just at token boundaries — so `eval document.getElementById('telefono').value` used to silently become `document.getElementById(telefono).value` (quotes gone). That bare `telefono` then resolved via the browser's legacy "elements with an `id` become `window` globals" quirk to the actual `<input id="telefono">` DOM node instead of the string `"telefono"`, so `getElementById(thatNode)` returned `null` and `.value` threw — a confusing null-property error with no hint the quotes were the problem. Fixed: `eval` now takes everything after the first space verbatim, no shlex. If this driver is edited again, don't route `eval`'s argument through `shlex.split()`.
- **Browser tab caching bites real users, not just this driver.** A person testing changes in an already-open browser tab (not a fresh `driver.py` run, which always launches a clean browser) can see "nothing changed" after an edit because the tab kept the pre-edit `app.js`/`styles.css` in memory — a hard refresh (or closing and reopening the tab) is the fix, not a code bug. Worth ruling out before debugging a "my change didn't apply" report.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `playwright._impl._errors.Error: Executable doesn't exist` | Run `python3 -m playwright install chromium` (browser binary wasn't downloaded yet). |
| `command not found: npx` / `node` / `brew` | Expected on this machine — this skill's whole reason for existing. Use `driver.py`, not chromium-cli. |
| Server curl-polls succeed but page looks stale | Old `http.server` process still bound to 8080 from a previous run — kill it first (see Gotchas). |
| `console --errors` shows `401`/`400` right after a login submit | Expected — that's Supabase rejecting the intentionally-wrong test credentials, not an app bug. |
