---
name: estate
description: Always loaded with global. This installation's machines, where things live, and who keeps each layer. The only place they are written down.
---

# The estate

When the estate changes, this file changes in the same commit.

## Machines

| Name | What it is | Login | Reach it |
|---|---|---|---|
| `hive` | Linux VPS. **All compute:** code, Rex's server, rexconfig, the work engine, every agent | `jrg` | you are usually on it |
| `m5` | Josh's MacBook. **Runs only the Rex app** (with its built-in server), Chrome, his eyes and hands | `jrg` | `ssh m5 <cmd>` from hive |
| `m1` | A second Mac | `jcbbge` | not reachable yet |

- You can reach every machine; never say a file is out of reach because it lives elsewhere. If the link
  itself fails, say which link and what it printed.
- A file is read and written where it lives, never copied to work on it.
- Nothing Rex runs on the M5 except the app (Josh, 2026-11-20). Rex config, Lua and every Rex
  script live and run on hive; never run a Rex command on the M5 over ssh. The app reaches
  hive's Rex server through its host `hive`.
- Every cross-machine check covers both hive and the M5.
- Hive's clock is America/Chicago: write times as CT.

## Layers, bottom up

1. **Machine:** the OS and its services (systemd `--user` on hive). Keeper: `hive-oracle`.
2. **Rex:** the room. Hive's server (`rex.service`) shows every session, pane and agent and carries
   their messages; the M5 app shows it. It holds nothing durable. A pane's address is its session and
   block (`REX_SESSION`, `REX_BLOCK`). Keeper: `rex-oracle`.
3. **rexconfig** (`~/rexconfig`: Rex config,
   the agent commands `start-work`, `agent-send` (delivered through the work engine's Rex bridge: receipts, holds, queues), `agent-ask`, `agent-close`, `scratch`, the hook
   `agent-hook`, and the task views). Install with `~/rexconfig/install`. Keeper: `rex-oracle`.
4. **The work engine: Rivet.** It holds everything durable: sessions, tasks, to-dos, agent runs. A
   session actor spawns task actors; each task runs the work's grammar and hires its agents. The live
   engine belongs to a private project, whose own repo documents it. The old engine (`rv`) is stopped
   since 2026-11-15; `rv` prints where its history is. The file stores agents still use (scratchpads,
   receipts, run files, identity) are moving into Rivet and are not there yet. Keeper: `rivet-oracle`.
5. **Agents:** Claude, Codex, pi, any model, run on hive. Josh starts one clean with `rex claude|codex|pi`;
   other work starts as a task from a Rex block, and its agents are disposable hands for one step each
   (`start-work` launches one today). Research, planning and review on Claude; coding on Codex.
6. **Roles:** taken only when Josh types the command in an agent: `/seat` (the agent he works a project
   with), `/hive-oracle`, `/rex-oracle`, `/rivet-oracle`. Each runs `agent-role <role>`, which labels the
   pane (one holder per role) and loads `~/agent-core/primitives/directives/<role>/DIRECTIVE.md`.

## agent-core

This repo is the source of every instruction. It is **public**: nothing private (a project's layout,
ports, schema, internals) goes in it. Change it, push, then `git -C ~/agent-core pull` on hive and the
M5; the post-merge hook writes each harness's instructions.
