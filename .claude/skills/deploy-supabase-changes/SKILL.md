---
name: deploy-supabase-changes
description: Deploy schema/SQL changes, RLS policy updates, or edge function updates to the real GilMuffler-App Supabase project via the web dashboard (no Supabase CLI installed on this machine) — walks Luis through it one numbered step at a time, confirming each step worked before the next.
---

Luis is not a trained programmer. Every step here must be small, numbered, and confirmed before moving to the next — never dump the whole procedure at once. This mirrors the rule already in `CLAUDE.md`.

## Reference

- Supabase project ref: `tussmuklnvqwkbdcjwtq`
- Dashboard base: `https://supabase.com/dashboard/project/tussmuklnvqwkbdcjwtq`
- SQL editor: `https://supabase.com/dashboard/project/tussmuklnvqwkbdcjwtq/sql/new`
- Table editor / RLS policies: `https://supabase.com/dashboard/project/tussmuklnvqwkbdcjwtq/auth/policies`
- Edge Functions: `https://supabase.com/dashboard/project/tussmuklnvqwkbdcjwtq/functions`
- No `supabase` CLI is installed here — everything below is dashboard-only (copy/paste + click).

## Process

1. **Explain first.** Before giving any steps, tell Luis in plain language what's about to change and why — not code, the real-world effect (e.g., "esto hace que solo tú puedas ver la lista de clientes, no cualquiera con el enlace").
2. **Break it into one dashboard action per numbered step.** E.g.:
   - "1. Abre este enlace: <url>"
   - "2. Pega este código: ```sql\n...\n```"
   - "3. Haz clic en 'Run' (o el botón correspondiente)."
3. **Stop after each step and wait for confirmation** (what Luis saw, or a simple "sí funcionó") before giving the next step.
4. **If something looks wrong or unexpected, stop and troubleshoot** before continuing — don't assume it worked.
5. **After all steps are done**, summarize what changed in plain terms and suggest verifying it — e.g. re-run `/run-gilmuffler-app` or reload the app in a real browser.
6. **Never paste real secrets** (service_role key, database password) into the chat — Luis already has those in the dashboard and in `config.local.js`.

## Notes

- If a change is actually a code file (e.g. an edge function's `index.ts`), the dashboard's function editor accepts pasted code directly — no CLI/build step needed for this project.
- Cross-reference the pending-fixes list in project memory ([[project-gilmuffler-app]]) before deploying anything, so known issues aren't reintroduced.
