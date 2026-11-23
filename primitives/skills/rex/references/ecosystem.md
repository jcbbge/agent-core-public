# Rex as an ecosystem: how it is extended, and how this estate extends it

Read when you add anything to Rex: a key, an action, a view, a watcher, a harness extension, a
plugin from someone else. Measured on Rex API revision 13 (hive 0.0.1794460237, M5 0.1.0-preview.16),
2026-11-15. Evaluation behind it, with file and line citations:
`~/rivet/work/tasklist/r12/rex-eval.md` and `rex-eval-detail.md`. Rex's docs: `~/research/rex/docs`,
`rex __internal skill`, `rex api list|describe --json`.

## Where things are seen, and where they run

Josh, 2026-11-15: "im only using rex on my macbook m5 ... we dont have to support linux. the m5 is
the hands." Every visual, popup, float, palette action, key and notification targets the Rex app on
the M5 only, and is designed and proven there. Programs in panes (applets, scripts, teerex) still run
on hive's Linux, where compute and its Rex server live: that is running, not viewing. Where a choice
trades Linux-client support for a better Mac experience, take the Mac.

**The M5 runs only the Rex app** (Josh, 2026-11-20: "i dont want anything to run on the m5 ... any
fukcing thing that has to do with rex, i do not want it on my m5 except the mac app"; the same day:
"the app is connected to the server. the server is connected to the app. it doesnt matter where they
are located"). The app and its own built-in server count as the app. No rexconfig, Rex Lua, teerex,
rex-check or Rex script is installed or run there, and no agent runs a Rex command on it over ssh.
Checks that need the app's view run on hive: the reserved-key check reads the app's cached key list
from the Mac as plain files.

## Keys: never on a key that is already taken

Josh, 2026-11-19, after `cmd+alt+w` (bound to the work rundown) closed his tabs: never bind a key
the Rex Mac app or macOS already uses. On the M5, the app's menu shortcuts and macOS's standard
shortcuts fire before a config binding. `cmd+alt+w` is macOS's Close All, and the app has its own
Close Other Tabs and close-all-windows commands.

- `rex keymap` with no `--request` lists only the config layer. A clean result there proves nothing
  about the app or macOS. Check against the app's full shortcut list (its settings, or a
  `client.keymap` request carrying the app's layers) and against macOS's standard shortcuts.
- A key you cannot prove is free stays unbound, and the action lives in the palette.
- Never test a key by pressing it in Josh's app; prove it with the keymap check.
- One exception (Josh, 2026-11-20): a key macOS uses **only in Finder** counts as free in Rex, because
  Finder shortcuts never fire inside another app. It is that narrow: a key with any system-wide,
  standard app-menu or Rex app meaning stays reserved. `cmd+j` turned out not to qualify: Josh's press
  in the app reached no Rex server (macOS's standard Find menu has Jump to Selection there), so it is
  reserved and the next-waiting jump is `cmd+alt+j`. A key is free only when it reaches Rex.
- Proof a key works, without pressing it: the app's cached `client.keymap` reply for the server
  (`~/Library/Caches/com.superlogical.rex/Keymap/<host>/*.json` on the M5, read as a file) lists it.
  Whether a press reaches the server shows in that server's log as a `client.action` from `rex-app-N`.
- rexconfig's check, `keys/check_keys.py`, refuses a binding on a reserved key in `./install`,
  `./install --check` and its tests. Its list is `keys/reserved.txt`; Finder-only keys are marked
  there and pass.

## Never refuse a newer Rex

Josh, 2026-11-20, after teerex refused Rex Preview (API 18) because its range stopped at 13: "how
does that make any sense to hard code a version ... it's in beta preview. it's going to change.
remove that check." No tool, applet or check ever refuses Rex for being newer. Detect features:
call the method, and if Rex answers `method_not_found` (or refuses the shape), say so plainly and
name the method. A minimum revision is fine where a method truly first appears; a maximum never is.

## What Rex offers an extension

| Point | Runs where | Can | Cannot |
|---|---|---|---|
| Config Lua (`init.lua`, `require`/`dofile` beside it) | inside the server, on every load and `rex config check` | actions, keys, sequences, modes, hosts | events, timers, API calls at load (docs `reference__lua.md` table) |
| Actions (`rex.action`) | server, when invoked | palette entry, key, `rex do NAME`, typed args | hide per pane; fill Rex's own pickers |
| Scripts (`rex do file.lua [--all]`) | their own process, as long as they run | events (`rex.on`), timers, every API call | define actions or keys that persist |
| Server API (`rex api call`, socket protocol `rex.control.v1`) | any program | everything a client can do; `--json` schemas | — |
| Program status (OSC 7501) | any program in a pane | idle/working/done/blocked/error records, read by tabs, pickers, Lua, `teerex observe` | — |
| Floating layers, detached blocks | API | overlays, drawers, pre-started hidden panes | — |
| Block creators / flavors | built into Rex | terminal flavors only | third parties cannot add a block type |
| Hosts (`rex.host`, `rex -S`) | client | reach another machine's server | — |
| Harness extensions (pi `.pi/agent/extensions`, Claude hooks) | inside the agent | call `rex do`/`rex api`/teerex from the agent's own events | — |

## How people extend it now (five repos and leaf, Nov 2026)

- **Lua module with `setup(opts)`** loaded from config: leaf, amber, rexd's Amber-compatible plugins.
- **Installer that edits `init.lua`** then `rex config check` and reload: leaf, rex-extensions'
  `install.js`, rexd. All three write the user's config; here that file is rexconfig's.
- **Plugin managers**: amber (Lua, git checkouts plus a lockfile), rexd (Go daemon plus launchd,
  manifest `rex-plugin.toml` with a minimum `rex_api`).
- **Pane program plus thin Lua**: leaf; rex-extensions' github and mcc panels (Node in a split).
- **Detached watcher scripts started at config load**: rex-extensions' tabs and sshtab; rexd's supervisor.
- **Client library over the socket protocol**: rexuikit (Go, Bubble Tea, written for revision 7).
- **Harness extensions using Rex**: the pi runbook (runs steps in hidden Rex blocks via `rex do`).

Converging conventions: `setup(opts)` modules; action names prefixed by the extension; pane labels as
the only state; check config before reload and restore on failure; declare the API revision you need;
a README "what it runs and writes"; OSC 7501 for status.

## What is stable enough to build on

| Stable enough | Evidence |
|---|---|
| OSC 7501 program status | a revisioned, generic spec (0.4, 2026-10-10); unknown keys ignored by rule |
| The config/script split | documented per function in `reference__lua.md` |
| `rex api … --json` self-description | every method carries schemas |
| Old clients keep working | a revision-7 client (rexuikit) negotiated revision 7 against the revision-13 server, 2026-11-15; `server.version` omits `api_min_revision` (docs: missing means 0) |

| Not stable | Evidence |
|---|---|
| The API revision itself | 7 on 2026-10-23 (rexuikit's snapshot) to 13 on 2026-11-12: six revisions in 20 days |
| Builds | hive runs a 0.0.x development build, the M5 a preview; docs publish no deprecation policy |
| Pixel geometry of layers | rexuikit had to measure chrome constants from the Mac app (the only client that matters here; re-measure after app updates) |
| Plugin hooks | none for pickers or per-pane actions; leaf rewrites config to fake one |

## This estate's architecture

| Piece | What lives there | Wired into Rex by | Installed | Tested without live Rex |
|---|---|---|---|---|
| rexconfig (`~/rexconfig`) | `init.lua` and its Lua, palettes, keys, actions that start things, agent commands (incl. `agent-steps`), the work board, `rex-check`, the behaviours list, harness hooks | itself: the only writer of Rex config | `./install` on hive and the M5 (links) | `rex do tests/*.lua`; Lua policy as pure modules |
| Applets | plain Python standard-library scripts in a pane ([rex-applet skill](../../rex-applet/SKILL.md)) | a rexconfig action, if one is wanted | the project's checkout; nothing on PATH | `--replay` frames, PTY test |
| teerex | observe, watch, compare, guarded sends, cooperative holds, pane operations, records and recovery | nothing | pinned hive build, `~/rexconfig/teerex.version` | its own suite (upstream) |
| Event scripts | `rex do x.lua --all` reacting to events | a palette action starts each in a visible, labelled pane (`automation.lua`) | rexconfig | pure modules under `rex do` |
| Harness extensions | per harness: pi extensions, Claude/Codex hooks | nothing; they call `rex do`, `rex api`, teerex | agent-core-sync / rexconfig hooks | the harness's own tests |
| Others' Lua plugins (leaf today) | `~/.config/rex/plugins/<name>/` | rexconfig's guarded `dofile` | by hand, a pinned version | `rex config check` |

Rules that hold across all of them:

- **One writer for Rex's config: rexconfig.** No installer, plugin manager, applet or daemon edits
  `~/.config/rex/*`. A third-party installer is read for what it would add; rexconfig adds that.
- **Nothing starts on its own.** No watcher launched at config load, no daemon, no LaunchAgent. Long
  scripts run in a visible labelled pane that closing stops.
- **Names**: one lowercase word `<app>` → command, pane label, status id `<app>/<kind>`, action
  `<app>_<verb>` titled "`<App>`: Verb" in category `<App>`, env `<APP>_*`, state `~/.local/share/<app>/`.
- **API revision**: each piece names the lowest revision it was tested on, in one constant, and checks
  it once before its first Rex call with `rex-check api --need N --who <name>` (exit 3 and one line:
  "<name> needs Rex API N; <host> runs M"). Lua checks at action time with rexconfig's helper, never at
  load. Pieces that only call teerex rely on teerex's own refusal.
- **Behaviours the docs do not promise** live in one list, rexconfig `docs/rex-behaviours.md`, each
  with a probe. `rex-check` runs them all in one throwaway session on hive. Something new that relies on an unpromised behaviour adds its row and probe there.
- **Rex updates** are noticed, not polled: the session-start hook runs `rex-check watch` (well under a
  second when nothing changed). On a version change it runs the probes in a visible pane, diffs the API
  field by field, and pages Josh's inbox once only if something we use broke, a listed want arrived,
  or something we hand-rolled can be retired (the lists are in the behaviours doc). Otherwise it records.
- **Ask-first actions Josh must run** go to him as runnable steps with `agent-steps submit`
  (rexconfig README), not as chat.
- **Final proof** runs in a throwaway session on the live server (`session.create`, then
  `session.destroy`), never in Josh's sessions.
- **Docs**: a README per piece; this file for the shape; the rex-applet skill for applets.

rexconfig's `./install` checks the resulting Rex config in a temporary home before linking, and puts its
changes back if the live config then fails to load (since 2026-11-15).
