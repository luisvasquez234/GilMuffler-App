---
name: pre-deploy-check
description: Run a combined security and accessibility check on pending GilMuffler-App changes before deploying or shipping them — runs the built-in /security-review plus the frontend-security-accessibility-reviewer subagent together as one pre-flight check.
---

Use before pushing/deploying any new change to the real shop app — a quick "is this safe to ship" pass, not a full repo re-audit.

## Process

1. Check `git diff` / `git status` (in whichever copy of GilMuffler-App is being worked on) for pending changes. If nothing changed, say so plainly and stop — don't run the checks against nothing.
2. Run `/security-review` on the pending diff.
3. If any changed files are frontend (`.html`, `.css`, `.js`), delegate to the `frontend-security-accessibility-reviewer` subagent (via the Agent tool), scoped to only the changed files/lines — not a full-app re-audit unless explicitly asked.
4. Merge both sets of findings into one prioritized list (HIGH/MEDIUM/LOW) in plain language for Luis.
5. Don't re-flag issues already tracked as known/pending in project memory ([[project-gilmuffler-app]]) unless this change makes one of them worse — cross-check that list first.
6. If everything's clean, say so directly rather than padding the report.
