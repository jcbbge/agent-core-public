---
name: rex
description: Rex is the control plane for every agent on the M5 and on hive - sessions, tabs, panes, running and reading terminals, controlling Rex apps - plus teerex, the Rex extensions CLI, for bounded terminal reads, waits and supervised runs. Use for any Rex task, any time an agent starts, reads, waits on or talks to another pane, or lays out work across machines.
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
- **Start agents visibly:** with `agent-spawn` (below) or `rex run -- <agent> ...`, never with `&`,
  `nohup`, a background flag or a launchd job.
- **Never restart the Rex server or kill Rex processes** without the operator's yes. A restart
  closes every pane. Before asking, write the accounting: every tab, what it runs, where, its
  resume command, and any unsent input that would be lost.
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
teerex compare --before before.json --after after.json          # offline, no Rex call
teerex run --socket "$sock" --cwd "$PWD" --timeout-ms 600000 -- npm test   # local argv, exit evidence
```

- `watch` exits 0 on a change, 124 on deadline, 1 on error. A change or a `done` report is
  evidence, not success: check the program's exit (`teerex run` receipt, or
  `rex block call ... process` → `last_exit`).
- Use one `watch` instead of any sleep-and-capture loop.
- teerex reads only. To type into a pane use `rex send` / `rex send-key`, never into your own pane
  or the operator's pane.
- If teerex reports `unsupported Rex API revision`, the server is older than teerex supports. Use
  `rex capture --trim` until Rex is updated, and say so in your report.

## 4. Agents talk to each other through Rex

The protocol is [agent-messaging](../../rules/agent-messaging/RULE.md); the verbs live in
`tools/agent-messaging`:

- `agent-spawn <session> <name> -- <command...>` starts an agent in a new visible tab and prints
  its pane. It passes `AGENT_REPORT_TO` (you) so the agent reports back to you.
- `agent-send <session> <pane> <your name> <message...>` is the only way to send.
- `agent-read <session> <pane>` only to confirm delivery.
- Questions for the human go to the **seat** with `agent-send`; the seat's pane is an inbox and is
  never typed into.

Hive agents are started from the M5's Rex as `ssh -t hive "cd <dir> && exec <agent> ..."`. Pass
the pane address across: `LC_REX_SESSION` / `LC_REX_BLOCK` and `LC_AGENT_*` ride over ssh. On
hive, `rex` talks to the M5's Rex server.

## 5. Long output is a document

Anything for the human longer than a few lines goes in a `.md` file, opened in `leaf` beside your
pane:

```sh
rex split -s "$REX_SESSION" -b "$REX_BLOCK" --split=right --focus=false -- leaf open /abs/path/file.md
rex split -s "$S" -b "$B" --split=right --focus=false -- ssh -t hive 'leaf open /home/jrg/.../file.md'
```

## 6. Layouts that pay off

- One tab per agent, named for its work (`agent-spawn` does this). Supporting panes (leaf, logs,
  dev server) split beside the agent they serve, `--focus=false`.
- Dev servers and watchers: `rex window new ... --keep-open --focus=false -- <cmd>`. Record the
  block id and close it when your work lands.
- Tests and builds: `teerex run` when you only need the result; `rex run --wait --keep-open` when
  the human should see the output.
