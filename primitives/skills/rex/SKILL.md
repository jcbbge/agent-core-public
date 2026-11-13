---
name: rex
description: Rex is the terminal control plane on the M5 and on hive - sessions, tabs, panes, running and reading terminals, controlling Rex apps - plus teerex (alpha.5), the Rex extensions CLI - bounded reads and waits, supervised runs, visible agents and messages, panes it opens/moves/closes, the fleet board, restart snapshot/restore, named hosts. Use for any Rex task, any time an agent starts, reads, waits on or talks to another pane, lays out work across machines, or before a Rex restart.
---

# Rex

## 1. Load the official guide first

Run `rex __internal skill` and follow the guide it prints. It ships with the installed Rex CLI, so
it matches that version's commands. If it fails, the installed Rex predates the guide: start with
`rex whoami --json`, then `rex --help` and `rex COMMAND --help`.

Everything below adds to that guide. Where they differ, this file wins.

## 2. The law

- **Agents should run on hive**, whatever app is their window. Rex is one window; T3 Code, Claude
  Desktop and a plain terminal are others. The [engine-host](../../hooks/engine-host/HOOK.md) guard
  suggests it (a Mac launch opens on hive) and refuses nothing for the machine. A Rex pane is not required.
- **Use Rex and teerex for everything they do.** teerex is the operating layer built for agents:
  panes, reads, waits, runs, agents, messages, the seat, boards and restarts all go through it. Never
  hand-build Rex plumbing beside it (wrapper scripts, split-and-resize code, log tailers, restart
  scripts, fallbacks). Where teerex cannot do a thing yet, file a jcbbge/teerex issue and say so in
  your report; do not build around it.
- **Start agents visibly** through teerex (`agent-spawn` calls `teerex agents launch` from configured profiles), never with `&`, `nohup`, a background flag or a launchd job.
- **Never restart the Rex server or kill Rex processes** without the operator's yes. A restart
  closes every pane. Before asking, run `teerex recovery update --socket "$sock" --snapshot` (the
  panes at risk, plus a private snapshot) and write what it cannot know: each agent's resume
  command and any unsent input. Section 7 has the restore.
- **Name the session for the work only in a session you own.** Never rename a shared session.

## 3. Read and wait with teerex, not `rex capture`

teerex ([TOOL.md](../../tools/teerex/TOOL.md)) gives bounded, attributed reads that state what
they don't know (unknown freshness, partial prefixes) and never infer completion. The guard sends
`rex capture` here whenever teerex works against the connected server.

```sh
sock="$HOME/Library/Application Support/rex/server.sock"   # or decode $REX_SERVER
teerex observe --socket "$sock" --session "$S" --block "$B" --max-bytes 8192 > before.json
# Wait for the pane to change, or for its program to report a status:
teerex watch --socket "$sock" --session "$S" --block "$B" --baseline before.json \
  --timeout-ms 60000 [--status-state done|blocked|error [--status-id ID]]
teerex compare --before before.json --after after.json          # offline, same pane only
teerex filter --sample a.json --sample b.json                   # offline, drops repeats
teerex run --socket "$sock" --cwd "$PWD" --timeout-ms 60000 -- npm test   # Mac: argv + real exit
```

- Addresses are full lowercase `session:UUID` / `block:UUID`; short suffixes and labels are
  refused (teerex#2). Get them from `rex block list -s "$S" --json`.
- `--max-bytes` is 256–65536 (default 4096). `compare` refuses two different panes.
- `watch` exits 0 on a change, 124 on deadline, 1 on error. A change or a `done` report is
  evidence, not success: check the program's exit (`teerex run` receipt, or
  `rex block call ... process` → `last_exit`).
- Use one `watch` instead of any sleep-and-capture loop.
- `offstage` (Mac) runs one short non-agent command in a throwaway terminal and closes it.
- These commands read only. To type into an agent's pane use `agent-send` (below), never your own
  pane or the operator's.
- If teerex reports `unsupported Rex API revision`, the server is older than teerex supports. Stop
  and tell your starter; updating Rex is the operator's call.

## 4. Agents talk to each other through Rex

The protocol is [agent-messaging](../../rules/agent-messaging/RULE.md); the verbs live in
`tools/agent-messaging`:

- `agent-spawn --brief-file brief.md [--owner owner] [--purpose purpose] <session> <name> -- <claude|codex|pi>`
  uses managed launch from `~/.config/teerex/profiles.json`, passing your own pane as starter and report-to.
  Profiles must exist; ACK precedes the brief and the job and fleet entry carry owner and purpose.
  `--non-agent` is required for a non-agent command through low-level `teerex spawn`.
- `agent-send <session> <pane> <your name> <message...>` is the only way to send.
- `agent-read <session> <pane>` only to confirm delivery.
- Questions for the human go to the **seat** with `agent-send`, typed straight into its pane.

All agents and the seat run on hive's Rex server; the M5 Rex app is the window. A caller on
hive launches into hive. An M5-server caller is refused (jcbbge/teerex#14); never invent a cross-host route.

## 5. Long output is a document

Anything for the human longer than a few lines goes in a `.md` file, opened in `leaf` beside your
pane:

```sh
teerex surfaces open --socket "$sock" --session "$S" --layout tiled --anchor "$B" --direction right \
  --label doc -- ssh -t hive 'leaf open /home/jrg/.../file.md'
```

## 6. Layouts that pay off

- One tab per agent, named for its work (`agent-spawn` does this). Supporting panes (leaf, logs,
  dev server) open beside the agent they serve with `teerex surfaces open --layout tiled --anchor`.
- Dev servers and watchers: `teerex surfaces open --layout tab --label <name> -- <cmd>`. Record the
  block id and close it with `teerex surfaces close` when your work lands.
- Tests and builds on hive: `teerex run-visible` (read its `--help` for explicit environment and stdin files). On the Mac, `teerex run` also provides bounded argv execution.

## 7. The teerex operating layer (alpha.5)

Composed commands for running agents on Rex. All are explicit and foreground: no daemon, no hidden
agent, no automatic retry or close. Every pane they open is visible and yours to focus or close.
Full flags: `teerex <command> --help`.

| Command | Use it when | Example |
|---|---|---|
| `surfaces` | You need a tiled, floating or tab pane with its real geometry read back, or to move, focus or close one by address. | `teerex surfaces open --socket "$sock" --session "$S" --layout float --label logs -- tail -f app.log` |
| `jobs` | You track who owns a pane, or bring a finished pane beside you. Never closes anything. | `teerex jobs present --registry "$REG" --socket "$sock" --session "$S" --block "$B" --owner seat --generation 1 --reason review --anchor "$ME" --focus no` |
| `boards fleet` | The operator wants the live read-only fleet board. Not for messages: the seat has no inbox; message it with `agent-send`. | `teerex boards fleet --store "$ST" --config "$HOME/.config/teerex/hosts.json" --hosts m5,hive` in a visible tab |
| `agents` | Managed launch from a profile: the agent ACKs the protocol before one brief, its job is tracked, its stop is reported honestly. | `teerex agents launch --config "$PROFILES" --profile worker --brief-file brief.md …` |
| `recovery` | Before a Rex restart: `update --snapshot` lists panes at risk; `snapshot` saves layout and launch metadata; `restore` previews, then applies on an empty server. | `teerex recovery update --socket "$sock" --snapshot` |
| `targets` | A command should run on a named machine (`m5`, `hive`, `m1`) from one hosts config, not a socket path. | `teerex --config "$HOSTS" --host hive observe …` |
| `fleet install` | Install or roll back teerex on a named machine: plan first, `--apply` to do it. | `teerex fleet install --config "$HOSTS" --host hive --version v0.1.0-alpha.5 --apply` |
| `doctor`, `adapters`, `maneuver-check` | Check the server offers what teerex needs (Mac); generate five read-only Rex tools for an agent; check a saved read against an expected starting screen. | `teerex doctor --socket "$sock"` |

Hive profiles live at `~/.config/teerex/profiles.json`; validate with
`teerex agents profiles --config ~/.config/teerex/profiles.json`. Named hosts live at
`~/.config/teerex/hosts.json`. Managed launch records protocol ACK before attempting one brief,
tracks the job, and gives the fleet board owner and purpose. A recorded ACK is not readiness;
a finished turn is idle, not process death. Inspect an uncertain launch before retrying.
`agent-send` uses `teerex send`; stop hooks report to the starter. Gaps belong in
jcbbge/teerex, never in hand-built transport beside it.

Rex and teerex configuration is owned by `~/rexconfig` on each machine. See its README
and `./install --check`; agent-core-sync does not install or replace those files.
