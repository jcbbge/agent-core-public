---
name: estate
description: Always loaded with global. This installation's machines, how they connect, and the layers of control. The only place they are written down.
---

# The Estate

The machines, the links between them, and who controls what. The global directive is portable;
this file is this installation. When the estate changes, this file changes in the same commit.

## You can reach every machine

You run on one machine and reach every other one from it: run commands, read and write files,
start and message agents. Never tell the operator you cannot access a file because it is on
another machine. Reach it by its name. Only when the reach itself fails (a timeout, a refused
login), say which link failed and what it printed.

| Name | What it is | Role | Login | Reach it from anywhere |
|---|---|---|---|---|
| `hive` | Linux VPS (Hivelocity) | **All compute.** Code, Rivet, agents and their files live here. | `jrg` | `ssh hive <cmd>` |
| `m5` | MacBook (M5), the operator's laptop | **The terminal.** Rex app, Chrome, the operator's eyes and hands. Mac-only tools. | `jrg` | `ssh m5 <cmd>` (from hive) |
| `m1` | MacBook (M1) | **A second Mac.** Its files and Mac-only tools. | `jcbbge` | `ssh m1 <cmd>` (being set up: its tunnel to hive is not in place yet, so this fails until it is) |

- Each Mac holds one always-on tunnel to hive and lends hive its login: the M5 at hive's port
  2222, the M1 at 2223. So hive reaches every Mac, and every Mac reaches every other through hive,
  on any network. On the M5 that tunnel is `hive-tunnel` (launchd), which also carries the
  forwards: Rivet engine at the M5's 127.0.0.1:6420, hive's Rex server at `~/.ssh/rex-hive.sock`,
  the M5's Chrome to hive's 127.0.0.1:9222.
- Connections are shared (ControlMaster): a second `ssh <name> <cmd>` costs under 0.1 s. Call it
  as often as the work needs.
- **Finder view, on the M5 (being set up):** `~/Machines/hive` (hive's home) and `~/Machines/m1`
  (the M1's home) are the other machines' files. They are a view for the operator, not a second copy: an agent
  works on a file where it lives, over ssh.

## Where things live (one place each)

- Code, checkouts, Rivet, work items, agent sessions, inboxes: **hive**.
- Anything the operator looks at (Rex windows, Chrome, Finder): **m5**.
- A file never gets copied between machines to work on it. Read and write it where it lives.
  Copy only to hand it to a tool that cannot reach it (then say so).

## The layers of control

From the ground up. Each layer only drives the one above it.

1. **Machine.** The OS, its services (launchd on a Mac, systemd `--user` on hive), PATH, ssh.
2. **Rex.** The terminal control plane. Every agent runs in a Rex pane, nothing hidden. The Rex app
   runs on the m5; a Rex server runs on each machine (hive: `~/opt/rex/bin/rex`, `rex.service`).
   A pane's address is its session and block (`REX_SESSION`, `REX_BLOCK`; over ssh,
   `LC_REX_SESSION`, `LC_REX_BLOCK`).
3. **teerex.** Bounded reads of a Rex pane (observe, watch, run), plus read-only adapters with
   receipts. Use it instead of `rex capture` and sleep loops. Installed: v0.1.0-alpha.4 on m5 and
   hive (`~/.local/opt/teerex-managed`; alpha.3 kept in `~/.local/opt/teerex`). Where it works today:
   on the m5 against the m5's Rex server, everything except `jobs` (the m5 server is Rex API10;
   jobs needs API13). On hive, `observe` / `watch` / `jobs` cannot read the agent panes (they are
   hosted on the m5): jcbbge/teerex#10. From hive, read a pane with `rex block capture` until it is
   fixed.
4. **Rivet.** The engine on hive (127.0.0.1:6420, `rivet-node.service`, CLI `rv`). It drives work
   items through discovery, planning, implementation, tests, audit and the ship stop. Projects
   are inputs from `~/rivet/projects/<name>/`; the engine names no project.
5. **Agents.** Claude, Codex, pi and the rest, any model. An agent is started by typing its name
   (`claude`, `codex`, `pi`): its standing flags are added for you, and outside a Rex pane it
   opens itself in a new Rex tab. Agents talk with `agent-send` / `agent-spawn` / `agent-ask`.
6. **The seat.** The one agent the operator types to. Its pane is an inbox; questions for the
   operator go there, as decision cards.

## Words

- **Machine**: one of the names above. **Host** means the same.
- **Pane / block**: one terminal in Rex. **Tab / window**: a Rex tab.
- **Seat**: the agent the operator talks to. **Inbox**: the seat's message log on hive.
- **Item**: a piece of Rivet work (a discovery or a task). **Promote**: turning a discovery's
  candidate tasks into tasks. **Ship stop**: where finished work waits for the operator's QA.
- **Project**: a folder of inputs Rivet reads (`~/rivet/projects/<name>`).
- **agent-core**: this repo, the source of every instruction every agent loads. Changed here,
  pushed, then `agent-core-sync` on each machine.
