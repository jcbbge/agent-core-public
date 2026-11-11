# Rex ideas 4, 5, 7, 9, 10, 11, 12, 13, 14: build plan

For: Codex Sol, who builds this exactly, in `~/work/agent-core-rex` (branch `rex-ideas`). Do not commit.
Source: `~/research/rex/ideas.md` (the ideas), `~/research/rex/docs/` (the Rex docs, cited below as `docs/<file>`).
Not in scope (done or dropped): idea 1 (notifications, dropped by Josh: build **no** OSC 7501 reports, sounds or
desktop notifications anywhere), 2, 3, 6, 8. Idea 3's action is changed here only because idea 14 needs it to step
both ways (section 14).

## 0. Ground rules for the build

**Where things run.** The Rex server, its config (`~/.config/rex/init.lua`) and the real `agent-send`/`agent-spawn`
run on the **Mac** (home `/Users/jrg`, host alias `m5` from hive). Agents, `agent-inbox`, `agent-seat` and the
`agent-*-hive` forwarders run on **hive** (Ubuntu 22.04, uid 1000). On hive, `~/.local/bin/rex` is a shim that runs
the Mac's rex over `ssh m5`. Neither you nor the planner has ssh: every Mac-side piece is a file in this repo, and
`rex/INSTALL.md` is the exact list of commands the seat runs.

**Files this plan creates or changes** (nothing else):

| Path (repo-relative) | Runs on | Ideas |
|---|---|---|
| `rex/init.lua` | Mac (later hive, idea 12) | 3 (changed), 4, 9, 11, 14 |
| `rex/watch.lua` | Mac (later hive) | 4, 9, 10 |
| `rex/bin/rex-flight` | hive | 5 |
| `rex/bin/rex-hive-actions` | hive | 11 |
| `rex/bin/rex-hive-sync` | Mac | 11 |
| `rex/bin/rex` | hive (replaces the shim) | 12 |
| `rex/launchd/local.rex-watch.plist` | Mac | 4, 9, 10 |
| `rex/launchd/local.rex-hive-forward.plist` | Mac | 12 |
| `rex/systemd/rex-flight@.service` | hive | 5, 12 |
| `rex/systemd/rex-watch.service` | hive | 12 |
| `rex/tests/run.sh` | here (the fence) | all testable parts |
| `rex/INSTALL.md` | (instructions) | all, text in the INSTALL.md section |
| `primitives/tools/agent-messaging/agent-spawn` | Mac | 4 |
| `primitives/tools/agent-messaging/agent-send` | Mac | 7 |
| `primitives/tools/agent-messaging/agent-launch` (new) | Mac | 11 |
| `primitives/tools/agent-messaging/agent-seat` | hive | 9, 12 |
| `primitives/tools/agent-messaging/agent-inbox` | hive | 9 |
| `primitives/tools/agent-messaging/relay/agent-send-hive` | hive | 12 |
| `primitives/tools/agent-messaging/relay/agent-spawn-hive` | hive | 12 |
| `primitives/hooks/rex-context/HOOK.md` (new) | hive | 13 |
| `primitives/hooks/rex-context/scripts/rex-context` (new) | hive | 13 |

Keep the house style of the existing scripts: a header comment that says what the file does and why, in plain words;
`set -euo pipefail` in bash; python3 with the standard library only; no new dependencies. Every new script is
executable (`chmod +x`).

**Shapes to check with `rex api describe` before trusting them.** The docs give the method names and fields below;
they do not spell out these result or argument shapes. Write the code to the shape given here, mark each use with a
comment `-- CHECK: <command>` (or `# CHECK:`), and copy the list into INSTALL.md's step 0 so the seat runs them first.

| # | Assumed shape | Check with |
|---|---|---|
| C1 | Terminal flavor is `com.superlogical.terminal.shell`; its options take `command` (list), `label` goes beside `flavor` | `rex block types --json`; `rex api describe block_creator.list` |
| C2 | `session.new_block` returns `{block_id}` | `rex api describe session.new_block --json` |
| C3 | `session.new_layer` returns `{layer_id, block_ids[]}` | `rex api describe session.new_layer --json` |
| C4 | `session.view` → `windows[]` each with `window_id`, `focused_block_id`, `layers[]` each with `layer_id`, `kind` (`tiled`/`floating`), `state` (absent or `minimized`), `layout` (nodes `{block:{block_id,label}}` or `{split:{before,after,ratio}}`); top level `active_window_id`, `session_id` | `rex api describe session.view --json` |
| C5 | `session.list_blocks` → `blocks[]` with `block_id`, `label`, `placement` (`placed`/`detached`), `creator_name` | `rex api describe session.list_blocks --json` |
| C6 | `com.superlogical.terminal.program_status` → `records[]` with `id` (absent = root), `state`, `kind`, `app`, `msg` (decoded text), `updated_at` | `rex api describe com.superlogical.terminal.program_status --json` |
| C7 | `terminal.program_status_changed` gives `ev.id`, `ev.record` (same fields as C6), `ev.reason` | `rex events -s <session> --json` while a Claude agent works |
| C8 | `com.superlogical.terminal.set_theme` takes `{background = "#rrggbb"}` and `{}` restores the default | `rex api describe com.superlogical.terminal.set_theme --json` |
| C9 | `com.superlogical.terminal.format` takes `{format = "text"\|"vt", trim = true}` and returns `{text}` | `rex api describe com.superlogical.terminal.format --json` |
| C10 | Client action `session.select` takes `{session_id}` | `rex -C <app client> actions --json \| jq '.[] \| select(.name=="session.select")'` |
| C11 | Key names `space`, `escape`, `enter`, `shift+cmd+j`, `shift+cmd+i` are valid and free | `rex keymap \| grep -E 'cmd\+(shift\+)?[ji]'` after reload |
| C12 | `rex block ls -A --json` → list of blocks with `block_id`, `label`, `session_id` | run it once |

---

## Build order

13 → 5 → 7 → 14 (with the idea-3 change) → 11 → 4 → 9 → 10 → 12. Small and independent first; the shared watcher
(`watch.lua`) is built once in 4 and extended by 9 and 10; idea 12 last and fully reversible.

---

## 13. Agents read the live API and docs as data (hive)

**What it does.** Every Claude session that starts on hive gets a short block of context saying where the live Rex
API description is cached and how to look things up, so agents call Rex with exact shapes instead of guessing.

**Files.**
- `primitives/hooks/rex-context/HOOK.md`: frontmatter `name: rex-context`, `description: At session start, tells
  the agent where the live Rex API description and docs are.` Body in the house format: **Event:** session-start.
  **Adds** (it refuses nothing). **When it cannot tell:** prints nothing and exits 0. **Off switch:** remove the hook
  entry. `scripts/` holds a reference implementation.
- `primitives/hooks/rex-context/scripts/rex-context` (bash):
  ```bash
  command -v rex >/dev/null || exit 0
  C="${XDG_CACHE_HOME:-$HOME/.cache}/rex"; F="$C/api.json"; mkdir -p "$C"
  # Refresh in the background when missing or older than 6 hours, so session start never waits on ssh.
  if [ ! -s "$F" ] || [ -n "$(find "$F" -mmin +360 2>/dev/null)" ]; then
    ( timeout 20 rex api list --json > "$F.tmp" 2>/dev/null && [ -s "$F.tmp" ] && mv "$F.tmp" "$F" || rm -f "$F.tmp" ) \
      </dev/null >/dev/null 2>&1 & disown
  fi
  cat <<EOF
  Rex (the terminal multiplexer this session runs in) has a self-describing API. Never guess a method's arguments:
  - Exact schema of one method: rex api describe <method> --json   (e.g. session.new_split)
  - Every method, cached: $F   (jq '.. | objects | select(.name? == "session.view")' $F)
  - Find a docs section: curl -s 'https://www.superlogical.com/rex/docs/search.json?q=<words>'
  - The full guide for agents: rex skill show
  Rex says "block" for what agent messaging calls a "pane"; the ids are the same.
  EOF
  ```
  (Write the heredoc unindented in the real file.) The `jq` path expression is deliberately shape-agnostic because
  the top-level layout of `api list --json` is not documented (`docs/automate__server-api.md`, "Machine-Readable
  Documentation" lists only per-method fields).
- Add a row for `rex-context` nowhere else: README tables list primitives by kind, not by item.

**Test (here).** `bash -n`; `shellcheck`; run it with a stub `rex` first on `PATH` (stub prints `{}`), assert it
prints the six lines and exits 0; run it with no `rex` on `PATH`, assert empty output and exit 0. In
`rex/tests/run.sh`.

**Install.** INSTALL step 13: merge the hook into `~/.claude/settings.json` on hive (with a backup).

---

## 5. Flight recorder (hive)

**What it does.** One always-on hive service writes every agent state change, exit and close to a JSONL file per day,
named by agent, so "when did the implementer stop, and why?" is a file read, not a question to a person.

**File `rex/bin/rex-flight`** (python3).
- `rex-flight record [--server mac|hive]`: runs `rex events --all --json` (for `hive`, `/usr/bin/rex events --all
  --json`; for `mac`, plain `rex`, which is the shim) as a subprocess, reads lines, and appends one record per
  interesting event to `~/.local/state/rex-flight/<UTC date>.jsonl`, flushing each line. Exits non-zero when the
  stream ends (systemd restarts it).
- Event unwrapping, per `docs/reference__events.md` "Events on the CLI": an outer `{"type":"session_event",
  "payload":{"session_id", "event":{...}}}`; a terminal event is `event.type == "block_event"` with
  `payload.{block_id, creator_name, name, payload}`. Keep:
  - `block_event` with `name` in `program_status_changed` (fields `id`, `record`, `reason`), `program_status_removed`
    (`ids`, `reason`), `child_exited` (`exit_code`, `error`);
  - session events `block_created`, `block_closed` (`block_id`).
  Ignore everything else.
- Record: `{"at": UTC ISO, "server": "mac"|"hive", "session": id, "block": id, "agent": label or "",
  "event": name, "state", "kind", "app", "msg", "exit_code", "reason"}`, omitting empty keys. Only root
  status records (no `id`, or empty) are agent state; child records are written with `"sub": id`.
- `msg`: the record may carry it decoded or as base64 (C6/C7). Use it as is unless it is valid strict base64 that
  decodes to printable UTF-8 with no spaces in the original; then decode.
- Agent name = the block's label. Keep a `block_id → label` cache; on a miss, run `rex block ls -A --json` (C12) at
  most once every 10 s and refill. `block_closed` drops the entry after writing.
- `rex-flight show [NAME] [-n 20]`: prints the last N records (today and yesterday's files), filtered to agent NAME
  if given, one line each: `HH:MM:SS  agent  state/event  msg`. This is what the seat and Rivet read.

**File `rex/systemd/rex-flight@.service`** (systemd user template; `%i` is `mac` or `hive`):
```ini
[Unit]
Description=Rex flight recorder (%i): agent state changes to ~/.local/state/rex-flight
[Service]
ExecStart=%h/.local/bin/rex-flight record --server %i
Restart=always
RestartSec=5
[Install]
WantedBy=default.target
```

**Test (here).** `python3 -m py_compile`; feed a fixture file of event lines (the two JSON examples from
`docs/reference__events.md`, plus a `program_status_changed` with `record:{state:"blocked",kind:"question",
app:"claude-code",msg:"V2FpdGluZw=="}`, plus a `block_closed`) through a hidden `--stdin` flag (reads events from
stdin instead of spawning rex; label lookups use a stub `rex` on `PATH` that prints a fixed `block ls` JSON) with
`XDG_STATE_HOME` set to a temp dir. Assert the JSONL lines and that `show` prints them. In `rex/tests/run.sh`.

**Install.** INSTALL step 5: copy the script and unit, `systemctl --user enable --now rex-flight@mac`.

---

## 7. Typing guard in agent-send (Mac)

**What it does.** Before agent-send clears a pane's input line (ctrl+u) and pastes, it checks whether someone has
half-typed text there. If so it waits for them to finish (up to 30 s). If they are still mid-thought after that, it
delivers the message and then puts their draft back in the input line, so nothing he typed is ever lost.

**Change `primitives/tools/agent-messaging/agent-send`**, inside the lock, before the paste block:
```bash
# Typing guard (research idea 7): never erase a half-typed line.
draft() {  # prints the unsent text in the target's input line, or nothing
  "$T" block call -s "$S" -b "$P" format '{"format":"vt"}' 2>/dev/null | python3 "$GUARD_PY"   # CHECK: C9
}
```
- `GUARD_PY` is a small python program embedded with a heredoc into a temp file (or `python3 -c`), reading the
  `format` result JSON on stdin. It takes the screen text (`.text`), looks only at the last 15 non-empty lines, and
  finds the input line: the **last** line matching `^\s*[│┃|]?\s*[>❯]\s?(.*?)\s*[│┃|]?\s*$`. From the VT text of that
  line it drops every run of characters drawn dim or grey (SGR `2`, `90`, `38;5;240`–`38;5;250`, `38;2;r;g;b` with
  r=g=b < 160): that is Claude Code's greyed suggestion, which is not his text. What remains, stripped, is the draft.
  Print it, or nothing.
- Loop: `for i in $(seq 1 30); do d=$(draft); [ -z "$d" ] && break; sleep 1; done`.
- If `d` is still non-empty after the loop: deliver as today (ctrl+u, paste, Enter), then `sleep 0.4` and send one
  more `block.event` paste with `{"text": d}` and **no** Enter, and append one line
  `<UTC> <pane> draft restored (<len> chars)` to `~/.local/state/agent-send/guard.log`.
- The guard only runs on the paste path and the typed fallback path; inbox panes never reach it. If `format` fails
  (old server, wrong shape), `draft` prints nothing and agent-send behaves exactly as today.
- Holding the lock while waiting is right: other senders queue behind (the lock budget is 60 s, the guard's 30 s).

**Test (here).** `bash -n`, `shellcheck`. Extract the python guard into a testable form (`agent-send --guard-test`
reads a `format` JSON on stdin and prints the draft) and feed it three fixtures in `rex/tests/run.sh`: an empty
Claude input box, a box with greyed suggestion text only (`ESC[2m` / `ESC[90m`), and a box with `fix the tests`
typed in normal colour. Expect empty, empty, `fix the tests`.

**Seat test (Mac).** INSTALL step 7 has a calibration: type a few words in an idle agent pane without pressing Enter,
then `agent-send <session> <pane> test "guard check"` from hive. Expect a 30 s pause, then the message, then the words
back in the input line. If the guard misreads the box, capture the real screen with
`rex block call -s S -b P format '{"format":"vt"}' > ~/guard-sample.json` and send it back to the implementer.

---

## 14. Triage mode, and next_waiting steps both ways (Mac, init.lua)

**What it does.** One key enters an exclusive "triage" mode where no keystroke can reach an agent: `j`/`k` step to the
next/previous agent that is waiting, `z` zooms it, `space` toggles the Activity sidebar, `d` sends a detached fleet
agent back out of sight (idea 4), `i` shows or hides the inbox (idea 9), `escape` or `enter` leaves.

**Change to idea 3's `next_waiting` (needed, and a fix).** Today it skips the current pane and jumps to the oldest
waiting one, so with three waiting agents A, B, C, repeated presses go A→B→A→B and never reach C. Replace the "skip
current, take first" with a stable ordered walk:
- Collect every terminal block, **placed or detached**, whose root record (C6: no `id`) is `blocked`, `error` or
  `done`. Keep the current block in the list too.
- Sort by `rank` (blocked 1, error 2, done 3), then `updated_at`, then `block_id`.
- New typed arg `direction = "string?"` (`next` default, `prev`). Find the current block's index; take the
  next/previous entry, wrapping. If the current block is not in the list, take the first (next) or last (prev).
- If the chosen block is detached, place it first:
  `rex.session.move_block{session_id=sid, block_id=bid, anchor_block_id=ctx.block_id, direction="vertical",
  side="after", ratio=0.6}` (only when it is in the same session as `ctx`; otherwise place it beside that session's
  focused block from `session.view`, C4).
- Focus with `session.focus_block`. If `sid ~= ctx.session_id`, also
  `pcall(rex.client.queue, "session.select", { session_id = sid })` (C10) so the app shows that session.
- Message when empty stays "Nothing is waiting on you."

**Add to `rex/init.lua`:**
```lua
rex.mode("triage", { exclusive = true })
rex.bind("shift+cmd+j", "client.mode.enter", { name = "triage" })      -- CHECK: C11
rex.bind("triage/j", "next_waiting", { direction = "next" })
rex.bind("triage/k", "next_waiting", { direction = "prev" })
rex.bind("triage/z", "pane.zoom")
rex.bind("triage/space", "client.sidebar.activity.toggle")
rex.bind("triage/d", "fleet_dismiss")
rex.bind("triage/i", "inbox_toggle")
rex.bind("triage/enter", "client.mode.exit")
```
(`escape` already leaves a mode, `docs/customize__key-modes.md`.) `cmd+j` stays bound to `next_waiting`.
Mechanisms: `docs/customize__key-modes.md` (modes, exclusive, "a binding in a mode must name an action");
`docs/reference__mac-actions.md` (`pane.zoom`, `client.sidebar.activity.toggle`, `client.mode.exit`).

**Test.** Here: syntax only (see Tests). Mac: `rex config check`, then `rex keymap | grep triage` shows 7
bindings and `triage  yes` in the mode table; then `rex do ~/.config/rex/init.lua --action next_waiting
direction=prev` returns without error.

---

## 11. The hive launch menu and spawn_agent in the command palette (hive generates, Mac runs)

**What it does.** Everything in the hive login menu, and "start an agent with this brief", become command-palette
entries (Cmd+Shift+P → type → Enter) under "Hive", and the same names work from the CLI (`rex do spawn_agent
name=… brief=…`), with bad arguments refused before anything runs.

**Open fact.** `~/.config/hive/launch` was not readable by the research or the planner. Its format is unknown. The
generator below accepts simple formats and an override file; INSTALL step 11 has the seat check the result.

**File `rex/bin/rex-hive-actions`** (python3, runs on hive, prints Lua to stdout):
- Source: `~/.config/hive/actions.tsv` if it exists (lines `name<TAB>title<TAB>command`), else
  `~/.config/hive/launch`, parsed line by line, skipping blank lines and `#` comments, accepting
  `name<TAB>command`, `name = command`, `name: command`, or a shell `case` arm `name) command ;;`. Title = name with
  `-`/`_` as spaces, first letter capital.
- If any non-comment line fails to parse, or nothing parses: print nothing to stdout, print the unparsed lines to
  stderr, exit 2 (rex-hive-sync then keeps the old `hive.lua`).
- Output, one per entry: `rex.action{ name = "hive_<slug>", title = <title>, category = "Hive", keywords =
  <name and command words>, run = function(ctx) return HIVE.open(ctx, <command>, <title>) end }`, with every string
  emitted as a Lua long string or `string.format("%q")`-safe literal (write a `lua_str()` helper that escapes `\`,
  `"`, newlines and control bytes). Slug: lowercase, `[^a-z0-9]` → `_`.

**File `rex/bin/rex-hive-sync`** (bash, runs on the Mac):
```bash
AC_HIVE=${AC_HIVE:-'~/agent-core'}            # where agent-core lives on hive
D="$HOME/.config/rex"
if [ "$(uname)" = Linux ]; then               # the server runs on hive (idea 12): generate locally
  R=/usr/bin/rex; GEN=(bash -c "$AC_HIVE/rex/bin/rex-hive-actions")
else
  R="${REX:-/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex}"
  GEN=(ssh -o BatchMode=yes hive "$AC_HIVE/rex/bin/rex-hive-actions")
fi
"${GEN[@]}" > "$D/hive.lua.tmp" || { rm -f "$D/hive.lua.tmp"; exit 2; }
mv "$D/hive.lua.tmp" "$D/hive.lua"
sleep 1                                       # let the palette action that started us return first
"$R" config reload
```

**Add to `rex/init.lua`:**
```lua
local HOME = os.getenv("HOME")
local ON_HIVE = HOME:sub(1, 6) == "/home/"         -- true once the server runs on hive (idea 12)
local SHELL_FLAVOR = "com.superlogical.terminal.shell"   -- CHECK: C1
HIVE = {}                                           -- global: hive.lua's actions call it
function HIVE.argv(cmd)                             -- a command line to run on hive, from wherever the server is
  if ON_HIVE then return { "sh", "-lc", cmd } end
  return { "ssh", "-t", "hive", cmd }
end
function HIVE.open(ctx, cmd, title)
  local _, err = rex.session.new_window{ session_id = ctx.session_id, window_label = title, focus = true,
    layout = rex.layout.block{ flavor = SHELL_FLAVOR, options = { command = HIVE.argv(cmd) } } }
  if err then error(err, 0) end
end
pcall(require, "hive")                              -- generated by rex-hive-sync; absent is fine

rex.action{ name = "hive_refresh", title = "Refresh Hive Menu", category = "Hive",
  keywords = "launch menu sync reload hive",
  run = function()
    local h, err = rex.exec.start({ HOME .. "/.local/bin/rex-hive-sync" }, { detach = true })
    if not h then error(err, 0) end
    return { message = "Refreshing the Hive menu…" }
  end }

rex.action{ name = "spawn_agent", title = "Start an Agent…", category = "Hive",
  keywords = "agent claude spawn start brief new",
  args = { name = "string", brief = "string" },
  run = function(ctx, args)
    if not args.name:match("^[a-z0-9][a-z0-9-]*$") then error("name: lowercase letters, digits and dashes", 0) end
    local r, err = rex.exec({ HOME .. "/.local/bin/agent-launch", ctx.session_id, ctx.block_id or "", args.name },
      { stdin = args.brief, timeout = 25 })
    if not r then error(err, 0) end
    if not r.ok then error(r.stderr ~= "" and r.stderr or "agent-launch failed", 0) end
    return { message = "Started " .. args.name .. " (reports to the pane you launched it from)." }
  end }
```
Mechanisms: `rex.action` with `category`, `keywords`, typed `args` (`docs/reference__lua.md`, `docs/customize__actions.md`);
`require` beside init.lua (`docs/customize__config.md`, "Splitting Configuration"); `rex.exec`, `rex.exec.start
{detach=true}` (`docs/reference__lua.md`); reload refuses a running action (`docs/reference__api.md`,
`client.action`), hence the detached sync with a 1 s delay.

**New file `primitives/tools/agent-messaging/agent-launch`** (bash; runs where the real agent-spawn runs, the Mac):
`agent-launch <session> <report-pane> <name>`, brief on stdin.
```bash
# agent-launch: start a Claude agent on hive with a brief, in a visible tab, reporting to <report-pane>.
# The palette action spawn_agent calls this. The brief travels as a file, so no quoting can break it.
[ $# -eq 3 ] || { echo "usage: agent-launch <session> <report-pane> <name>  (brief on stdin)" >&2; exit 2; }
S=$1; P=$2; N=$3
[[ $N =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "agent-launch: bad name '$N'" >&2; exit 2; }
F=".local/state/agent-briefs/$N-$(date -u +%Y%m%dT%H%M%S).md"
{ printf 'Reply address: AGENT_SESSION=%s AGENT_PANE=%s. Report there with agent-send when you finish, stop or are blocked.\n\n' "$S" "$P"; cat; } \
  | ssh -o BatchMode=yes hive "mkdir -p ~/.local/state/agent-briefs && cat > ~/$F"
inner='exec ssh -t hive "export AGENT_SESSION=$AGENT_SESSION AGENT_PANE=$AGENT_PANE; cd ~ && exec ~/.local/bin/claude --dangerously-skip-permissions \"\$(cat ~/BRIEF)\""'
inner=${inner//BRIEF/$F}
AGENT_REPORT_TO="$S $P" exec "$HOME/.local/bin/agent-spawn" "$S" "$N" -- sh -c "$inner"
```
The inner `sh -c` expands `$AGENT_SESSION`/`$AGENT_PANE` on the Mac (agent-spawn exported them), and `\$(cat …)`
reaches hive's shell, which reads the brief as one argument. `AGENT_NAME`/`AGENT_REPORT_TO` cross ssh as their `LC_`
forms already (agent-spawn sets them). Every Claude started this way runs with `--dangerously-skip-permissions`
(standing ruling, 2026-11-11). With no `<report-pane>` (CLI call outside a pane) pass `""`: agent-spawn then falls back
to its own environment.

**Test (here).** `py_compile`; run `rex-hive-actions` with `HOME` pointed at a temp dir holding each launch format and
one bad file: assert generated Lua for good inputs, exit 2 and empty stdout for the bad one; assert a title containing
`"` and `\` is escaped. `bash -n` + `shellcheck` on `rex-hive-sync` and `agent-launch`; run `agent-launch` with stub
`ssh` and stub `agent-spawn` on `PATH`/`HOME` and assert the brief file content and the exact `sh -c` string.
**Mac.** `rex do spawn_agent name=launch-test brief="Say hi to your reply address with agent-send, then stop."`; a tab
opens on hive running Claude, and its message arrives in the pane you ran it from.

---

## 4. Detached fleet (Mac: agent-spawn, watch.lua, init.lua)

**What it does.** Agents can be started out of sight. When one needs Josh (its status turns blocked, error or done) it
slides in under the pane that started it; when it goes back to work it slides out again. The screen holds only the
agents that need him.

**Change `primitives/tools/agent-messaging/agent-spawn`.** Optional first argument `--detached`:
`agent-spawn [--detached] <session> <name> -- <command...>`. Usage check moves after the flag is consumed. When set:
```bash
SID=$("$T" api call -s "$S" session.view | python3 -c 'import json,sys;print(json.load(sys.stdin)["session_id"])')
J=$(jq -nc --arg s "$SID" --arg n "$N" --arg c "$ENVS;$CMD" \
  '{session_id:$s, flavor:"com.superlogical.terminal.shell", label:$n, options:{command:["sh","-c",$c]}}')   # CHECK: C1
B=$("$T" api call -s "$S" session.new_block "$J" | python3 -c 'import json,sys;print(json.load(sys.stdin)["block_id"])')  # CHECK: C2
A=${REPORT#* }                                       # the starter's pane: where this agent appears when it needs you
mkdir -p "$HOME/.local/state/rex-fleet"; printf '%s\n' "$A" > "$HOME/.local/state/rex-fleet/${B##*:}.anchor"
echo "$B"
```
Without the flag, behaviour is unchanged. `agent-spawn-hive` forwards all args, so `--detached` works from hive as is.
Mechanisms: `session.new_block` "starts detached: it runs, sends events, and answers method calls"
(`docs/reference__api.md`); every Rex terminal gets `REX_SESSION`/`REX_BLOCK` (`docs/automate__cli.md`).

**New file `rex/watch.lua`** (a `rex do --all` script; one watcher for ideas 4, 9 and 10). Structure:
```lua
-- watch.lua: Rex's always-on watcher. Run: rex do ~/.config/rex/watch.lua --all
-- 4: fleet agents appear when they need you and leave when they go back to work.
-- 9: the inbox layer rises when a new decision is waiting.  10: pane tint follows agent state.
local T = "com.superlogical.terminal"
local STATE = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
local function root(ev) return (ev.id == nil or ev.id == "") and ev.record end      -- CHECK: C7
local function fleet_anchor(bid)                    -- anchor pane id if bid is a fleet agent, else nil
  local f = io.open(STATE .. "/rex-fleet/" .. bid:match("[^:]+$") .. ".anchor"); if not f then return nil end
  local a = f:read("*l"); f:close(); return (a and a ~= "") and a or false
end
local function view(sid) return rex.call("session.view", { session_id = sid }) or {} end
local function focused(v) ... end                   -- focused_block_id of active_window_id (C4)
local function placement(sid, bid) ... end          -- from session.list_blocks (C5)
```
Fleet handlers:
- `rex.on("terminal.program_status_changed", fn)`: `r = root(ev)`; skip if nil. `a = fleet_anchor(ctx.block_id)`;
  skip if `a == nil`.
  - `r.state` in blocked/error/done and `placement == "detached"`: anchor = `a` if that block is placed in
    this session, else the focused block of the active window. `rex.session.move_block{ session_id=ctx.session_id,
    block_id=ctx.block_id, anchor_block_id=anchor, direction="vertical", side="after", ratio=0.6 }`;
    A placed block does not take focus (`docs/reference__api.md`, `move_block`), so
    nothing he is typing is interrupted.
  - `r.state == "working"`, the block is placed, and it is not the focused block of the active window:
    `detach_block`. The rule reads only Rex's own state and the anchor file, never memory, so it holds after the
    watcher restarts and whoever placed the block (this watcher, `next_waiting`, or Josh by hand).
- `rex.on("block_closed", fn)`: `os.remove` the block's `.anchor` file.
- Every handler is wrapped in `pcall` and logs failures with `rex.log("warn", ...)`; the script never stops on one
  bad event.

**Add to `rex/init.lua`:** `fleet_dismiss` (title "Send Agent Out of Sight", category "Agents"): if
`ctx.block_id`'s anchor file exists, `rex.session.detach_block{ block_id = ctx.block_id }`, else return
`{ message = "This pane is not a fleet agent." }`. `next_waiting` (section 14) already places detached fleet agents.

**New file `rex/launchd/local.rex-watch.plist`** (Mac LaunchAgent): `Label` `local.rex-watch`; `ProgramArguments`
`[<rex path>, "do", "/Users/jrg/.config/rex/watch.lua", "--all"]`; `RunAtLoad` true; `KeepAlive` true;
`ThrottleInterval` 10; `StandardOutPath`/`StandardErrorPath` `/Users/jrg/Library/Logs/rex-watch.log`.

**Test (here).** Syntax (see Tests). **Mac.** From hive: `agent-spawn --detached <session> fleet-test -- sh -c
'printf "\033]7501;state=working\033\\\\"; sleep 5; printf "\033]7501;state=blocked:kind=question\033\\\\"; sleep 600'`
— the block exists in `rex block ls` and no tab opens; after 5 s it appears under the starter pane. This test writes
OSC 7501 only to drive the test; it is not a notification and nothing in the shipped code emits one. Close it with
`rex block close <id>` and check the anchor file is gone.

---

## 9. The inbox as a floating layer that rises for decisions (hive: agent-seat, agent-inbox; Mac: watch.lua, init.lua)

**What it does.** The seat keeps its full width. The inbox floats over the right third, and can be hidden with one key;
when a new decision card arrives it rises by itself (without taking focus, so his typing is never interrupted).

**Change `primitives/tools/agent-messaging/agent-inbox`.** In `render()`, when `TTY`, write the terminal title first:
`sys.stdout.write(f"\033]2;Inbox · {len(open_)} waiting\007")`. A title is not a notification; it is how the
watcher learns the count. Nothing else changes.

**Change `primitives/tools/agent-messaging/agent-seat`.** Replace the `rex run --split=right` creation with a
floating layer, and keep today's split-and-resize code as the fallback when the layer call fails:
```bash
SID=$(rex api call -s "$S" session.view 2>/dev/null | python3 -c '...session_id...')
W=$(...same view...: the window_id whose layers contain block $B)            # CHECK: C4
CMD="TZ=$tz ~/.local/bin/agent-inbox $id"
J=$(jq -nc --arg s "$SID" --arg w "$W" --arg c "$CMD" '{session_id:$s, window_id:$w, bounds:[0.667,0,0.333,1],
  focus:false, layout:{block:{flavor:"com.superlogical.terminal.shell", label:"inbox",
  options:{command:["ssh","-t","hive",$c]}}}}')                               # CHECK: C1, C3
if out=$(rex api call -s "$S" session.new_layer "$J" 2>>"$D/seat.log"); then
  v=$(printf '%s' "$out" | python3 -c 'import json,sys;print(json.load(sys.stdin)["block_ids"][0])')
  printf '%s\n' "$v" > "$D/$id.viewer"; exit 0
fi
# fallback: the split as before (research idea 8)
```
Mechanisms: `session.new_layer` with fractional `bounds` and `focus` (`docs/reference__api.md`).

**Add to `rex/watch.lua`:** `rex.on("terminal.title_changed", fn)`: if the block's label is `inbox` (cache labels
from `session.list_blocks`, C5) and `ev.title` matches `(%d+) waiting`: when the number is higher than the last one
seen for that block, find its layer in `session.view` (C4) and, if `state == "minimized"`,
`rex.session.set_layer_state{ layer_id = L, state = "normal" }` then `rex.session.raise_layer{ layer_id = L }`.
Remember the count either way.

**Add to `rex/init.lua`:** `inbox_toggle` (title "Show or Hide the Inbox", category "Agents"): find the layer that
holds a block labelled `inbox` in `ctx.session_id`'s active window; toggle `set_layer_state` between `normal` and
`minimized` (never with `focus`). Bind `rex.bind("shift+cmd+i", "inbox_toggle")` (C11); triage `i` uses it too.

**Test (here).** `bash -n`, `shellcheck`, `py_compile`; run agent-inbox once with output to a pty (`script -qc`)
against a temp log holding one DECISION-JSON line; assert the title escape with `1 waiting`. **Mac.** Log in from a
fresh tab (`ssh hive`): the inbox is a floating panel on the right third; `shift+cmd+i` hides and shows it; with it
hidden, `agent-ask` a test decision to the seat: the panel comes back and focus stays in the seat.

---

## 10. State-tinted panes (Mac: watch.lua)

**What it does.** An agent's pane background takes a faint cast for its state: amber while it waits on him, red on
error, green when done and not yet looked at; it returns to normal when he focuses it (done) or it goes back to work.

**Add to `rex/watch.lua`:**
```lua
-- Taste lives here: one faint cast per state, close to the default background. Glyph-kit palette is the reference.
local TINT = { blocked = "#231c0e", error = "#24110f", done = "#0f1f15" }
local tinted = {}          -- block_id → state it is tinted for
local function tint(sid, bid, state)
  local args = TINT[state] and { background = TINT[state] } or {}                     -- CHECK: C8
  rex.block.call(T, "set_theme", { session_id = sid, block_id = bid, args = args })   -- CHECK: C8 (args nesting)
  tinted[bid] = TINT[state] and state or nil
end
```
- In the `program_status_changed` handler (shared with 4): for a root record of any terminal (not only fleet), tint
  on blocked/error/done, untint on working/idle; `program_status_removed` with the root id untints.
- `rex.on("session_view_changed", fn)`: get the view; if the focused block of the active window has
  `tinted == "done"`, untint it (he has seen it). Only call `session.view` when `ev.revision` is higher than the last
  one handled (`docs/reference__api.md`, `session.view`).
- Never tint the block labelled `inbox`.

Mechanisms: terminal `set_theme` (`docs/reference__lua.md`); `program_status_changed`, `session_view_changed`
(`docs/reference__events.md`).

**Test.** Here: syntax. Mac: the fleet-test agent from section 4 turns amber when blocked; focus it after a `done`
report and it clears.

---

## 12. The Rex server on hive (last; reversible)

**What it does.** A personal Rex server runs on hive, next to the agents. The Mac app connects to it over a forwarded
socket. Agents in hive-server tabs get a real `REX_SESSION`/`REX_BLOCK`, every `rex` call is local (no ssh hop), and
`rex skill setup` works natively. The Mac server keeps running; both coexist; going back is one rollback block.

**Design rule: nothing switches by a flag file.** Every hive tool picks the server by where its target lives:
- the `rex` shim: inside a hive-server terminal (`REX_SESSION` is set; ssh'd-in panes only carry `LC_REX_*`) it runs
  `/usr/bin/rex`; otherwise it runs the Mac's rex over ssh, as today;
- `agent-send-hive` / `agent-spawn-hive`: if `/usr/bin/rex` exists and `REX_AUTOSTART=0 /usr/bin/rex session inspect
  "$1"` succeeds, the session is on hive: run the real `agent-send`/`agent-spawn` from agent-core locally; otherwise
  forward to the Mac as today. Rollback therefore needs no edits to them.

**File `rex/bin/rex`** (the new hive shim; INSTALL backs up the old one to `~/.local/bin/rex.mac-only`):
```bash
#!/usr/bin/env bash
# rex on hive: the hive server for hive-server terminals (REX_SESSION set), else the Mac's rex over ssh (m5).
if [ -n "${REX_SESSION:-}" ] && [ -x /usr/bin/rex ]; then exec /usr/bin/rex "$@"; fi
REX="/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
args=$(printf " %q" "$@")
exec ssh -o BatchMode=yes -o ConnectTimeout=8 m5 "$(printf %q "$REX")$args"
```
Also: `rex-hive` is not needed; to reach the hive server from a plain hive shell use `/usr/bin/rex` directly.

**Changes `relay/agent-send-hive`, `relay/agent-spawn-hive`.** Before the final `exec ssh … m5`:
```bash
AC_TOOLS=${AGENT_CORE:-$HOME/agent-core}/primitives/tools/agent-messaging
if [ -x /usr/bin/rex ] && REX_AUTOSTART=0 /usr/bin/rex session inspect "$1" >/dev/null 2>&1; then
  PATH=/usr/bin:$PATH exec "$AC_TOOLS/agent-send" "$@"     # agent-spawn in the spawn forwarder
fi
```
(`PATH=/usr/bin:$PATH` makes the real scripts' `command -v rex` find the hive binary, not the shim.)

**Change `agent-seat`.** When `REX_SESSION` is set (a hive-server terminal), the viewer command is
`["sh","-lc", CMD]` instead of `["ssh","-t","hive", CMD]`; the session/pane come from `REX_SESSION`/`REX_BLOCK`
(already the fallback order).

**init.lua and watch.lua move with the server.** `init.lua` already picks `HIVE.argv` by `ON_HIVE` (section 11).
In `spawn_agent`/`hive_refresh`, the paths are `HOME .. "/.local/bin/…"`, which exist on hive too after INSTALL 12.
`agent-launch` on hive: when `ON_HIVE`, the brief is written locally and the inner command is
`exec ~/.local/bin/claude --dangerously-skip-permissions "$(cat ~/BRIEF)"` without ssh. Build this as a branch on
`[ -n "${REX_SESSION:-}" ]` / `[ "$(uname)" = Linux ]` inside agent-launch.

**File `rex/systemd/rex-watch.service`** (hive user unit): `ExecStart=/usr/bin/rex do %h/.config/rex/watch.lua
--all`, `Restart=always`, `RestartSec=10`, `After=rex.service`, `WantedBy=default.target`.

**File `rex/launchd/local.rex-hive-forward.plist`** (Mac): `ProgramArguments` `["/usr/bin/ssh", "-N", "-o",
"ExitOnForwardFailure=yes", "-o", "ServerAliveInterval=15", "-o", "ServerAliveCountMax=3", "-o",
"StreamLocalBindUnlink=yes", "-L", "/Users/jrg/.ssh/rex-hive.sock:/run/user/1000/rex/server.sock", "hive"]`;
`RunAtLoad` true; `KeepAlive` true; `ThrottleInterval` 10.

Mechanisms: personal server, socket path, `loginctl enable-linger`, systemd user unit `rex` from the Linux package
(`docs/linux__server-modes.md`, `docs/linux__installation.md`, `docs/reference__cli.md` `rex server logs`); SSH socket
forward and "Add Remote Host…" (`docs/linux__remote-access.md`). Hive is Ubuntu 22.04 (OpenSSH 8.9, so the
`xterm-rex` SSH fallback is safe, `docs/linux__installation.md` "The SSH Fallback").

**Trade-offs to state in INSTALL.** The hive server's sessions are new and separate; existing Mac sessions stay on the
Mac until closed. Mac-only actions do not exist in init.lua today (checked: the copy at `~/research/tabs/mac-init.lua`
uses no `osascript`). Rex's iOS app cannot use an SSH-forwarded socket (`docs/linux__remote-access.md`).

**Test (here).** `bash -n`/`shellcheck` on the shim and both forwarders; in `rex/tests/run.sh`, run the shim with a
`REX_SESSION` unset and a stub `ssh` on `PATH` that echoes its args (assert the m5 path; the `/usr/bin/rex` branch
cannot be stubbed here and is the seat's INSTALL 12 check); and run the forwarders with stub `ssh` and no `/usr/bin/rex` (assert they still forward
to m5). Everything else is the seat's INSTALL 12 verification.

---

## Tests: `rex/tests/run.sh`

One bash script, run from the repo root, exit 0 when everything passes, printing one line per check. It builds a temp
dir with stub `rex`, `ssh` and `agent-spawn` scripts on `PATH`, and covers the "Test (here)" items above. Lua syntax:
use `luac -p` if present; else `python3 -c 'import lupa'` (if installable with `uv pip install lupa` or
`pip install --user lupa`, load each file with `lupa.LuaRuntime().compile(...)`); else print `SKIP lua syntax (no
luac): the seat's rex config check covers init.lua` and continue. Install `lua5.1`/`luac` if this machine lets you
(standing ruling: installable is a choice, not a limit); report which path was used.

---

## INSTALL.md: write this file as `rex/INSTALL.md`

Write it with these sections, commands verbatim (fill only what is in angle brackets from your build). Each step
says where it runs, verifies, and says how to undo it. The seat runs Mac steps from hive with
`ssh m5 'bash -s' <<'EOF' … EOF`, and copies files with `scp`.

```
# Rex ideas: install

AC=~/work/agent-core-rex            # or ~/agent-core once merged
REX='/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex'   # on the Mac

## 0. Check the shapes (hive; uses the Mac server through the shim)
rex block types --json
rex api describe session.new_block --json
rex api describe session.new_layer --json
rex api describe session.view --json
rex api describe session.list_blocks --json
rex api describe com.superlogical.terminal.program_status --json
rex api describe com.superlogical.terminal.set_theme --json
rex api describe com.superlogical.terminal.format --json
rex block ls -A --json | head -c 600
rex actions -C <the Mac app's client label from `rex client ls`> --json | jq '.[] | select(.name=="session.select")'
If any shape differs from PLAN.md's table (C1–C12), send the output to the implementer before going on.

## Before anything: back up what is replaced
ssh m5 'cd ~/.config/rex && cp init.lua init.lua.bak-rex-ideas && ls -l ~/.local/bin/agent-send ~/.local/bin/agent-spawn'
ssh m5 cat .config/rex/init.lua | diff - ~/research/tabs/mac-init.lua   # must be empty; if not, merge by hand first
ssh m5 'cd ~/.local/bin && cp -P agent-send agent-send.bak-rex && cp -P agent-spawn agent-spawn.bak-rex'

## 13. Rex context for agents (hive)
mkdir -p ~/.local/bin && ln -sf $AC/primitives/hooks/rex-context/scripts/rex-context ~/.local/bin/rex-context
cp ~/.claude/settings.json ~/.claude/settings.json.bak-rex 2>/dev/null || echo '{}' > ~/.claude/settings.json
jq '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks":[{"type":"command","command":"'$HOME'/.local/bin/rex-context"}]}])' \
  ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
Verify: start `claude` on hive; its first answer to "what do you know about rex api?" cites the cache path.
Undo: mv ~/.claude/settings.json.bak-rex ~/.claude/settings.json

## 5. Flight recorder (hive)
ln -sf $AC/rex/bin/rex-flight ~/.local/bin/rex-flight
mkdir -p ~/.config/systemd/user && cp $AC/rex/systemd/rex-flight@.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now rex-flight@mac
Verify: rex-flight show -n 5   (after any agent changes state)
Undo: systemctl --user disable --now rex-flight@mac

## 7. Typing guard (Mac)
scp $AC/primitives/tools/agent-messaging/agent-send m5:.local/bin/agent-send.new
ssh m5 'cd ~/.local/bin && rm -f agent-send && mv agent-send.new agent-send && chmod +x agent-send'
Verify: the calibration in PLAN.md section 7.
Undo: ssh m5 'cd ~/.local/bin && rm agent-send && mv agent-send.bak-rex agent-send'

## 14, 11, 4, 9, 10. Rex config, watcher, palette, fleet, inbox layer, tints (Mac and hive)
scp $AC/rex/init.lua $AC/rex/watch.lua m5:.config/rex/
scp $AC/rex/bin/rex-hive-sync $AC/primitives/tools/agent-messaging/agent-launch m5:.local/bin/
scp $AC/primitives/tools/agent-messaging/agent-spawn m5:.local/bin/agent-spawn.new
scp $AC/rex/launchd/local.rex-watch.plist m5:Library/LaunchAgents/
ssh m5 'bash -s' <<'EOF'
cd ~/.local/bin && rm -f agent-spawn && mv agent-spawn.new agent-spawn && chmod +x agent-spawn agent-launch rex-hive-sync
REX='<as above>'
"$REX" config check || { cp ~/.config/rex/init.lua.bak-rex-ideas ~/.config/rex/init.lua; exit 1; }
~/.local/bin/rex-hive-sync        # writes hive.lua and reloads; if it exits 2, see step 11 below
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.rex-watch.plist
EOF
Step 11 if rex-hive-sync exits 2: look at ~/.config/hive/launch; write ~/.config/hive/actions.tsv
  (name<TAB>title<TAB>command per entry), then run it again.
On hive (agent-seat, agent-inbox come from agent-core through the existing symlinks): nothing to copy if
  ~/.local/bin/agent-seat and agent-inbox point into $AC; otherwise ln -sf them as the relay README does.
Verify: PLAN.md sections 14, 11, 4, 9, 10, "Mac" tests, in that order.
Undo (all five):
ssh m5 'bash -s' <<'EOF'
launchctl bootout gui/$(id -u)/local.rex-watch; rm -f ~/Library/LaunchAgents/local.rex-watch.plist
cd ~/.config/rex && cp init.lua.bak-rex-ideas init.lua && rm -f watch.lua hive.lua
cd ~/.local/bin && rm agent-spawn && mv agent-spawn.bak-rex agent-spawn && rm -f agent-launch rex-hive-sync
'<rex path>' config reload
EOF
(agent-seat falls back to the split on its own when the layer call fails; the agent-inbox title is harmless.)

## 12. Rex server on hive (last)
On hive:
curl -fsSL https://pkgs.superlogical.com/rex/install.sh | sh -s -- --dry-run     # read it, then:
curl -fsSL https://pkgs.superlogical.com/rex/install.sh | sh
cp ~/.local/bin/rex ~/.local/bin/rex.mac-only && cp $AC/rex/bin/rex ~/.local/bin/rex && chmod +x ~/.local/bin/rex
/usr/bin/rex version
mkdir -p ~/.config/rex && cp $AC/rex/init.lua $AC/rex/watch.lua ~/.config/rex/
ssh m5 cat .config/rex/hive.lua > ~/.config/rex/hive.lua 2>/dev/null || true
for f in rex-hive-sync; do ln -sf $AC/rex/bin/$f ~/.local/bin/$f; done
ln -sf $AC/primitives/tools/agent-messaging/agent-launch ~/.local/bin/agent-launch
loginctl enable-linger
systemctl --user enable --now rex                      # the package's personal-server user unit
/usr/bin/rex server status                             # shows the socket: expect /run/user/1000/rex/server.sock
/usr/bin/rex config check
cp $AC/rex/systemd/rex-watch.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now rex-watch rex-flight@hive
On the Mac:
scp $AC/rex/launchd/local.rex-hive-forward.plist m5:Library/LaunchAgents/
ssh m5 'launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.rex-hive-forward.plist; sleep 3; ls -l ~/.ssh/rex-hive.sock'
ssh m5 "'<rex path>' hosts add hive unix:///Users/jrg/.ssh/rex-hive.sock && '<rex path>' -S hive ls"
In Rex for Mac (by hand, once): Add Remote Host… → /Users/jrg/.ssh/rex-hive.sock
Then open a session on the hive host. In it: `echo $REX_SESSION` is set; `rex ls` answers with no ssh;
  `rex skill setup --agent claude` once on hive.
Verify: from a hive-server tab, agent-send to a hive-server pane delivers locally (no m5 in `ps` during it);
  agent-send to a Mac-session pane still forwards to the Mac.
Rollback (each line is safe on its own; sessions on the hive server end):
systemctl --user disable --now rex-watch rex-flight@hive rex
loginctl disable-linger
cp ~/.local/bin/rex.mac-only ~/.local/bin/rex
ssh m5 "launchctl bootout gui/\$(id -u)/local.rex-hive-forward; rm -f ~/Library/LaunchAgents/local.rex-hive-forward.plist ~/.ssh/rex-hive.sock; '<rex path>' hosts remove hive"
In Rex for Mac: remove the hive host.
Optional: sudo apt remove rex
agent-send-hive and agent-spawn-hive need no rollback: with no hive server they forward to the Mac as before.
```

---

## Open (for the seat; do not block the build on these)

1. `~/.config/hive/launch` was unreadable here; idea 11's parser covers common formats and falls back to
   `actions.tsv`. The seat confirms at INSTALL 11.
2. Every shape in C1–C12 comes from the docs, not the live server. INSTALL step 0 checks them first.
3. Idea 7's guard reads Claude Code's input box from the screen. The dim/grey rule is a reasonable guess; INSTALL 7's
   calibration confirms it on a real pane.
4. Idea 9 replaces idea 8's split with a floating layer. The split stays as the fallback, so idea 8 still holds when
   the layer call fails.
5. Idea 12 assumes the Linux package installs the personal-server user unit named `rex` (`docs/reference__cli.md`,
   `rex server logs`, says the Linux packages install it). If `systemctl --user cat rex` finds nothing after install,
   use `rex server start` from the `rex-watch` unit's `ExecStartPre=` instead.
6. Wording: Rex says "block", agent messaging says "pane"; same ids. Settling one word in agent-core is a backlog
   item, not part of this build.
