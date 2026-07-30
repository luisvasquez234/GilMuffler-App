#!/usr/bin/env python3
"""Minimal headless-Chromium REPL for driving GilMuffler-App.

No node/npm/chromium-cli on this machine, so this replaces chromium-cli
with a small Playwright-for-Python REPL. Same command vocabulary
(nav/click/fill/press/wait-for/screenshot/console) so it reads like the
chromium-cli sessions used elsewhere.

Usage:
    python3 driver.py <<'EOF'
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

Screenshots land in .claude/skills/run-gilmuffler-app/screenshots/<name>.png
(latest also copied to screenshot.png).
"""
import sys
import shlex
from pathlib import Path
from playwright.sync_api import sync_playwright

SCREENSHOT_DIR = Path(__file__).parent / "screenshots"
SCREENSHOT_DIR.mkdir(exist_ok=True)


def parse_target(arg):
    if arg.startswith("text="):
        return f"text={arg[5:]}"
    return arg


def main():
    console_messages = []
    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--no-sandbox"])
        page = browser.new_page()
        page.on("console", lambda msg: console_messages.append((msg.type, msg.text)))
        page.on("pageerror", lambda exc: console_messages.append(("error", str(exc))))

        for line in sys.stdin:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            try:
                parts = shlex.split(line)
            except ValueError:
                parts = line.split()
            cmd, args = parts[0], parts[1:]

            try:
                if cmd == "nav":
                    page.goto(args[0], wait_until="load")
                    print(f"ok: nav {args[0]}")
                elif cmd == "wait-for":
                    target = parse_target(args[0])
                    page.wait_for_selector(target, timeout=15000)
                    print(f"ok: wait-for {args[0]}")
                elif cmd == "click":
                    page.click(" ".join(args), timeout=10000)
                    print(f"ok: click {' '.join(args)}")
                elif cmd == "fill":
                    selector, value = args[0], " ".join(args[1:])
                    page.fill(selector, value, timeout=10000)
                    print(f"ok: fill {selector}")
                elif cmd == "press":
                    selector, key = (args[0], args[1]) if len(args) > 1 else ("body", args[0])
                    page.press(selector, key)
                    print(f"ok: press {key}")
                elif cmd == "screenshot":
                    name = args[0] if args else "screenshot"
                    dest = SCREENSHOT_DIR / f"{name}.png"
                    page.screenshot(path=str(dest))
                    (SCREENSHOT_DIR / "screenshot.png").write_bytes(dest.read_bytes())
                    print(f"ok: screenshot -> {dest}")
                elif cmd == "console":
                    errors_only = "--errors" in args
                    for kind, text in console_messages:
                        if errors_only and kind not in ("error", "pageerror"):
                            continue
                        print(f"[{kind}] {text}")
                    if errors_only and not any(k in ("error", "pageerror") for k, _ in console_messages):
                        print("ok: no console errors")
                elif cmd == "eval":
                    result = page.evaluate(" ".join(args))
                    print(f"ok: eval -> {result}")
                elif cmd == "quit":
                    break
                else:
                    print(f"error: unknown command '{cmd}'")
            except Exception as e:
                print(f"error: {cmd} failed: {e}")

        browser.close()


if __name__ == "__main__":
    main()
