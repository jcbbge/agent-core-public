---
name: task
description: "The session step list: now, later, done, and the gate that keeps it honest."
---

# tasks — the NOW / LATER / DONE ledger

One tool. No daemon, no database, no vendor.

| File | What |
|---|---|
| `task` | the CLI; bash + awk over a `TASKS.md` per project. `task help`. |

## Wiring

Put `task` on PATH. Wire the gate to four events (the hook events in the distro README): **session-start**
and **prompt** show the ledger; **before-tool** on edits, writes and shell commands refuses
unless NOW has an item written this session; **stop** refuses while NOW is open.

## What the hooks do

Enforcement is mechanical. The agent is never asked to remember the rule.

- At session start and on every prompt, the agent is shown the ledger.
- Edits, writes and shell commands are **denied** unless both hold: NOW has an
  open item, and the ledger was written during this session. A plan left over
  from yesterday does not count; the agent must write what it is doing now.
- A shell command is exempt only when every command in it is a `task`
  command, so the agent can always write its plan and can never smuggle
  another command in beside it.
- Ending a turn (or a subagent's turn) is **blocked every time** while NOW has
  open items. The three ways out are `task done`, `task defer`, `task drop`.
  A circuit breaker lets the turn end after `TASK_STOP_CAP` consecutive blocks
  (default 5) so a broken loop cannot burn tokens forever; it announces itself
  on stderr and resets.
- Session records live in `$XDG_STATE_HOME/tasks/sessions/<session_id>`.
- Everything fails open on a script error. `TASK_GATE=off` disables the gate
  for a session; the worker exception also applies.

## Format

`TASKS.md` is plain markdown the tool rewrites in canonical form:

```
# Tasks

## NOW

- [ ] #3 Look at the build

## LATER

- [ ] #2 @2026-MM-DD Wire the second harness

## DONE

- [x] #1 Build the ledger CLI (done YYYY-MM-DDTHH:MM:SSZ)
```

`task done <id>` moves an open NOW or LATER item into DONE, retaining its text and
adding a UTC ISO timestamp. Existing ledgers without DONE work unchanged. `task list`
shows NOW and LATER followed by `done N / planned M`, where planned is the sum of
retained completions and open NOW/LATER items; dropped items are not counted.

Ledger paths are remembered in `~/.config/tasks/roots` so `task all` can show
every project's open work at once.

The **before-tool** and **stop** enforcement follow the
[worker exception](../../rules/worker-guards/RULE.md): the worker's execution engine keeps
its steps on its own work item. The task CLI and informational session-start and
prompt events retain their behavior.
