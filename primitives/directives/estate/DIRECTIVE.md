---
name: estate
description: Always loaded with global. This installation's machines, where things live, and the layers. The only place they are written down.
---

# The estate

When the estate changes, this file changes in the same commit.

## Machines

| Name | What it is | Login | Reach it |
|---|---|---|---|
| `hive` | Linux VPS. **All compute:** code, Rex's server, rexconfig, the work engine, every task's steps | `jrg` | you are usually on it |
| `m5` | Josh's MacBook. **First contact** (below), the Rex app (with its built-in server), Chrome, his eyes and hands | `jrg` | `ssh m5 <cmd>` from hive |
| `m1` | A second Mac | `jcbbge` | not reachable yet |

- You can reach every machine; never say a file is out of reach because it lives elsewhere. If the link
  itself fails, say which link and what it printed.
- A file is read and written where it lives, never copied to work on it.
- **First contact is on the M5** (Josh, 2026-11-25). He starts a session there and gives a blanket order;
  it is taken in his words and submitted as a task's ticket in Rivet (global, rule 1). Whatever harness or
  model he starts there can reach both machines. Its guidebook is `~/rexconfig/oracle/GUIDEBOOK.md`
  (private); read it before acting across machines. Every task's steps run on hive.
- Rex config, Lua and every Rex script live and run on hive. The app reaches hive's Rex server through
  its host `hive`; a session on the M5's own built-in server has none of hive's actions or keys, except
  one linked config file for the app's own server (rexconfig `m5/rex/init.lua`, Josh 2026-11-25): the
  Rex app shortcuts he needs in every tab, starting with Cmd-Option-\ for the inbox.
- Every cross-machine check covers both hive and the M5.
- Hive's clock is America/Chicago: write times as CT.

## Layers, bottom up

1. **Machine:** the OS and its services (systemd `--user` on hive).
2. **Rex:** the room. Hive's server (`rex.service`) shows every session, task and pane and carries
   their messages; the M5 app shows it. It holds nothing durable. A pane's address is its session and
   block (`REX_SESSION`, `REX_BLOCK`).
3. **rexconfig** (`~/rexconfig`: Rex config,
   the commands `start-work`, `agent-send` (delivered through the work engine's Rex bridge: receipts, holds, queues), `agent-ask`, `agent-close`, `scratch`, `note`, the hook
   `agent-hook`, and the task views). Install with `~/rexconfig/install`.
4. **The work engine: Rivet.** It holds everything durable: sessions, tasks, to-dos, step runs. A
   session actor spawns task actors; each task runs the work's grammar and hires what runs each step. The live
   engine belongs to a private project, whose own repo documents it. The old engine (`rv`) is stopped
   since 2026-11-15; `rv` prints where its history is. Every record (scratchpads, receipts, runs) lives
   in Rivet, reached through rexconfig's commands.
5. **Steps:** a step runs on a harness and model (Claude, Codex, pi) named in its task's prescription,
   hired from the task for that step and gone after it. Josh can start a harness clean with
   `rex claude|codex|pi`. A layer's knowledge lives in its brief card (rexconfig
   `oracle/reserve/<layer>.md`), which goes into a task's brief.

## agent-core

This repo is the source of every instruction. It is **public**: nothing private (a project's layout,
ports, schema, internals) goes in it. Change it, push, then `git -C ~/agent-core pull` on hive and the
M5; the post-merge hook writes each harness's instructions.
