---
name: rex-applet
description: Build a Rex applet the settled way - a plain Python standard-library script that draws a live view in one Rex pane, reads its data through plain interfaces, reports status with OSC 7501, and never writes Rex's config. Use when asked for a dashboard, view, monitor or small interactive tool that lives in a Rex pane or floating layer. Viewed in the Rex app on the M5; usually runs on hive.
---

# rex-applet

An applet is one executable script in a pane. It reads, draws and reports; it never wires itself into
Rex. Where it sits among Rex's other extension shapes: [the rex skill's ecosystem reference](../rex/references/ecosystem.md).

## The settled shape (Josh's rulings)

- **Seen on the M5, run where the data is** (Josh, 2026-11-15: "the m5 is the hands. all
  visuals/ui/popups are read and viewed here on the m5"). Every view, float, palette action, key and
  notification is designed for and proven in the Rex app on the M5; no Linux client is supported.
  The program itself runs where its data lives, usually hive (Linux, Python 3.10); where a choice
  trades Linux-client looks for a better Mac experience, take the Mac.
- **Python standard library only**, one executable, no package install. The template also runs on
  the M5's Python 3.9. Not Rust ("this is a dashboard app layer"), not a Go/Bubble Tea kit.
- **Started by a command**, in a pane he can see. **Never writes Rex's config** ("leave config alone"):
  a palette action or key for it is added by rexconfig, by its owner, never by the applet.
- **Reads through plain interfaces**: a CLI with `--json`, a file, a local HTTP endpoint. It never
  embeds or writes its backend. Agents are messaged only through `agent-send`, never typed into.
- **Keys on screen, always** (Josh, 2026-11-15: "im not going to remember the open, close, mark unread,
  quit straightaway"). The last row of every screen, the help screen included, is a footer naming the
  keys in plain words ("j/k move · u mark unread · q close · ? all keys"), longest form that fits, never
  dropping `q` and `?`. `?` shows the full list. Scroll marks and notes sit at the footer's right end,
  never over content. The template's `pad`/`footer` do this.
- **No destructive single key** (Josh's dictation reached a panel and archived his whole inbox,
  2026-11-15). Anything that removes, archives or sends needs the same key twice within a moment
  ("press d again to archive"), says what it did, and has an undo key.
- **A burst guard on any panel that takes focus**: printable keys arriving faster than a person types
  (4 or more inside about 120 ms: dictation, a paste) are dropped, not run, with one line saying so.
  Text boxes inside the panel are exempt.
- **Position always shown**: where he is and how much is left ("fold 2 of 5", "lines 41 to 78 of 120"),
  never a jump he cannot place. Moving through items never changes their state (e.g. read).
- **The glyph-kit look**: ANSI colour slots only (the theme picks the shade), `NO_COLOR` honoured.
  `●` ok (green, 2), `▲` attention (yellow, 3), `✗` problem (red, 1), `○` idle or none, `▸` selected
  (cyan, 6), rules `─` (grey, 8 / 90), `░▒▓█` density, `▁▂▃▄▅▆▇█` sparklines.

Worked example: rexconfig's `bin/inbox` (a standard-library viewer in a floating Rex pane) and `bin/task-view`. Read them for scale, not to copy.

## Build one

1. **Name it** one lowercase word, `<app>`. The same word is the command, the pane label, the status
   id prefix (`<app>/<kind>`), the env prefix (`<APP>_*`) and the state folder (`~/.local/share/<app>/`).
2. **Lay out a repo** (its own, or a folder in the project it serves):
   ```
   <app>/<app>            the executable (from assets/applet)
   <app>/tests/test_<app>.py   from assets/test_applet.py
   <app>/fixtures/        recorded state.json for replay
   <app>/README.md        what it reads, its keys, how to start it, the Rex API revision it uses (if any)
   ```
3. **Copy the template** (paths relative to this skill's folder): `cp assets/applet <app>/<app>; chmod +x`,
   `cp assets/test_applet.py <app>/tests/test_<app>.py`; set `APP = '<app>'` in the executable and the
   default of `APPLET` in the test. The executable already has:
   pure `render(state, width, height) -> lines`, cell-exact `fit`, background reads with timeouts,
   a keys footer on every screen, alternate screen, synchronized output, changed-line redraw, SIGWINCH, OSC 7501 on `<app>/health`
   cleared on exit, terminal restored in `finally`, and `--once`, `--json`, `--replay DIR`, `--record DIR`.
4. **Replace `Sources.read`** with your sources. One `try` per source; a failure becomes the string
   `unavailable: <why>` and the rest still draw. Subprocesses: argv list (never a shell), a timeout,
   in the worker pool. Pass any log or prompt text through a redactor before it reaches the screen.
   An applet that takes arguments (a path, a host) adds them in `main` and passes them to `Sources(...)`.
5. **Replace `render` and `health`.** Views are pure functions of state; `health` returns the problems
   that set the status (`error` with the reason, `done` when clean). Keep the status record's id stable.
   Replace the test's `FIXTURE` and its unavailable-source case with your own state's shape.
6. **Record a fixture**: `./<app> --record fixtures` (refuses to overwrite). Check it holds no secret.
7. **Test without Rex**: `APPLET=<app> python3 -m unittest discover tests` on the machine it runs on
   (hive, usually; the M5 too only if it runs there). The
   frame tests read `--replay`; the PTY test proves draw, resize, keys, status and terminal restore.
8. **Start it** (no config change):
   - from the Mac (how Josh starts it; it runs on hive, he sees it in his app):
     `rex -S hive run --label <app> --shell=none -- ~/path/<app>/<app>`
   - from an agent on hive: `rex run --label <app> --shell=none -- ~/path/<app>/<app>`
   - floating over a pane: call Rex's `session.new_layer` with that pane's window ID, the desired bounds, and the applet's terminal command as the layout.
9. **Prove it live** in a throwaway session: `rex api call session.create '{"label":"<app>-proof"}'`,
   `rex run -s <session> --label <app> --shell=none -- <path>`, then
   `rex do com.superlogical.terminal.program_status -s <s> -b <b>` shows the `<app>/health`
   record. Clean up: `rex api call block.close '{"session_id":"<s>","block_id":"<b>"}'`, then
   `rex api call session.destroy '{"session_id":"<s>"}'`, then `rex api call session.list '{}'` shows it gone.
10. **Prove it where it is seen**: once, in the Rex app on the M5, with the size Josh uses. Ask the
    seat for that look (it holds his screen); never open tabs in his app on your own. Mac keys use
    `cmd`.
11. **Want a palette entry or key?** Ask the rex-oracle (or your starter) to add it to rexconfig. The
    action only starts the command above.

## If the applet talks to Rex

Use `rex api call --json` or `rex do script.lua --json --args '{…}'` (a Lua script for several calls
that must happen together); never the control socket directly. Name the lowest API revision you
tested on in one constant (a floor only; never refuse a newer Rex) and, before the first Rex call, run
`rex-check api --need <N> --who <app>`: on exit 3 show its one line and stay read-only. Every Rex
behaviour you rely on that its docs do not promise gets a row and a probe in rexconfig's
`docs/rex-behaviours.md`, so `rex-check` re-proves it after each Rex update (ask the rex-oracle).

## Never

Write `~/.config/rex/*` or rexconfig; reload Rex's config; start a background watcher or daemon;
install anything; paste into agent panes; draw colours by hex; keep state anywhere but
`~/.local/share/<app>/`; block the draw loop on a read.
