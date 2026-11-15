# Rex as an ecosystem: how it is extended, and how this estate extends it

Read when you add anything to Rex: a key, an action, a view, a watcher, a harness extension, a
plugin from someone else. Measured on Rex API revision 13 (hive 0.0.1794460237, M5 0.1.0-preview.16),
2026-11-15. Evaluation behind it, with file and line citations:
`~/rivet/work/tasklist/r12/rex-eval.md` and `rex-eval-detail.md`. Rex's docs: `~/research/rex/docs`,
`rex __internal skill`, `rex api list|describe --json`.

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
| Pixel geometry of layers | rexuikit had to measure chrome constants from the Mac app |
| Plugin hooks | none for pickers or per-pane actions; leaf rewrites config to fake one |

## This estate's architecture

| Piece | What lives there | Wired into Rex by | Installed | Tested without live Rex |
|---|---|---|---|---|
| rexconfig (`~/rexconfig`) | `init.lua` and its Lua, palettes, keys, actions that start things, agent commands, harness hooks | itself: the only writer of Rex config | `./install` on hive and the M5 (links) | `rex do tests/*.lua`; Lua policy as pure modules |
| Applets | plain Python standard-library scripts in a pane ([rex-applet skill](../../rex-applet/SKILL.md)) | a rexconfig action, if one is wanted | the project's checkout; nothing on PATH | `--replay` frames, PTY test |
| teerex | the utility over Rex: read, wait, send, surfaces, records, recovery | nothing | pinned build, `~/rexconfig/teerex.version` | its own suite (upstream) |
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
- **API revision**: each piece names the revision it needs; code that calls Rex reads `server.version`
  once and says so on a mismatch. After a Rex update: `teerex doctor --all`, then each piece's live check.
- **Behaviours the docs do not promise** are written down where they are relied on, with the check
  that re-proves them (rexuikit's `docs/rex-behaviors.md` plus `make live` is the model).
- **Final proof** runs in a throwaway session on the live server (`session.create`, then
  `session.destroy`), never in Josh's sessions.
- **Docs**: a README per piece; this file for the shape; the rex-applet skill for applets.

Known gap (2026-11-15): rexconfig's `./install` links Lua without running `rex config check` on the
result first; rex-extensions and rexd both check, and restore on failure.
