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
| `m5` | MacBook (M5), the operator's laptop | **The terminal.** Runs only the Rex app (with its own built-in server), Chrome, the operator's eyes and hands. Mac-only tools. | `jrg` | `ssh m5 <cmd>` (from hive) |
| `m1` | MacBook (M1) | **A second Mac.** Its files and Mac-only tools. | `jcbbge` | `ssh m1 <cmd>`: **not in place yet** (2026-11-14: hive cannot resolve `m1`; its tunnel is not set up) |

- Each Mac holds one always-on tunnel to hive and lends hive its login: the M5 at hive's port
  2222, the M1 at 2223. So hive reaches every Mac, and every Mac reaches every other through hive,
  on any network. On the M5 that tunnel is `hive-tunnel` (launchd), which also carries the
  forwards: Rivet engine at the M5's 127.0.0.1:6420. The M5's Chrome debug port is not forwarded at rest;
  an agent opens it on hive's 127.0.0.1:9222 for one browser task with operator-mac's `mac-cdp`.
- **The M5 runs only the Rex app (Josh, 2026-11-20: "i dont want anything to run on the m5 ... any
  fukcing thing that has to do with rex, i do not want it on my m5 except the mac app"; the same day:
  "the app is connected to the server ... it doesnt matter where they are located").** The app and its
  own built-in server are the app; leave them alone. Rex config and Lua, teerex, rex-check and every Rex
  script live and run on hive, and no agent runs a Rex command on the M5 over ssh. The app reaches
  hive's Rex server through its host `hive` (`ssh://jrg@hive/run/user/1000/rex/server.sock`). teerex
  runs on hive with one named host, `hive`, in `~/.config/teerex/hosts.json`. No hand-built socket forward.
- Connections are shared (ControlMaster): a second `ssh <name> <cmd>` costs under 0.1 s. Call it
  as often as the work needs.
- **Finder view, on the M5: not in place yet** (2026-11-14: `~/Machines` does not exist). When it
  is, `~/Machines/hive` and `~/Machines/m1` are a view for the operator, not a second copy: an agent
  works on a file where it lives, over ssh.

## Where things live (one place each)

- Rex and teerex configuration: `~/rexconfig` on hive; install with its `./install`. On the m5 the same
  checkout installs only the harness hooks, and `./install --check` reports any Rex tooling left there.
  Rex reads `~/.config/rex/init.lua`; teerex named hosts read `~/.config/teerex/hosts.json`.

- Code, checkouts, Rivet, work items, agent sessions: **hive**.
- Anything the operator looks at (Rex windows, Chrome, Finder): **m5**.
- A file never gets copied between machines to work on it. Read and write it where it lives.
  Copy only to hand it to a tool that cannot reach it (then say so).

## The layers of control

From the ground up. Each layer only drives the one above it.

1. **Machine.** The OS, its services (launchd on a Mac, systemd `--user` on hive), PATH, ssh.
2. **Rex.** The terminal control plane, and one window onto agents among others. The Rex app
   runs on the m5 with its own built-in server; hive's Rex server (`~/opt/rex/bin/rex`, `rex.service`)
   holds every session, pane and agent.
   A pane's address is its session and block (`REX_SESSION`, `REX_BLOCK`; over ssh,
   `LC_REX_SESSION`, `LC_REX_BLOCK`).
3. **teerex.** The Rex extensions CLI: bounded reads and waits, visible runs, safe whole-message sends,
   and the operating layer (panes, the board, restart snapshot/restore, named
   hosts). Every agent uses it for everything it does, and nothing is hand-built beside it; how is
   in the `rex` skill. Installed on hive only: the build pinned in `~/rexconfig/teerex.version`
   (`~/.local/opt/teerex-managed/current`; `teerex --version` and `readlink` of `current` say which).
   Earlier builds stay under `versions/` for rollback.
   Configuration and installation belong to `~/rexconfig`; see its README and `./install --check`.
4. **Rivet.** The engine on hive (127.0.0.1:6420, `rivet-node.service`, CLI `rv`). It drives work
   items through discovery, planning, implementation, tests, audit and the ship stop. Projects
   are inputs from `~/rivet/projects/<name>/`; the engine names no project.
5. **Agents.** Claude, Codex, pi and the rest, any model. **Agents should run on hive**, whatever
   app is their window (Rex, T3 Code, Claude Desktop, a terminal on any machine). This is a
   suggestion, not a block: nothing refuses an agent for the machine it is on. The operator starts
   one with `rex <agent>` (`rex claude`, `rex codex`, `rex pi`; Josh, 2026-11-15): a clean start with its
   standing flags, no role and no brief. On hive it starts in the terminal it was typed in; from a
   Mac it opens a visible tab labelled with its name on hive. Every other `rex ...` reaches the real Rex. Bare `claude`, `codex`, `pi` are the plain
   programs, and `seat` is no longer a command. Agents start agents with
   `agent-spawn`, talk with `agent-send`, keep their list with `scratch`, and send decision cards with
   `agent-ask` (all rexconfig; teerex carries no agent code).
6. **Roles.** An agent takes a role only when the operator types its command inside it; until then
   it is a plain agent. Each command runs rexconfig's `agent-role <role>`, which labels the pane with
   the role (one holder per role; a second asks him whether to move it), then loads the role file
   `~/agent-core/primitives/directives/<role>/DIRECTIVE.md`.
   - **`/seat`**: the agent he works a project with: project work, tasks, todos; it may start
     coordinators and workers; it is one pane, with nothing beside it. Agents reach it with
     `agent-send seat`; questions for the operator go there as decision cards.
   - **`/hive-oracle`**: the VPS: the machine, services, servers, runtimes, disks, network, where
     credentials live.
   - **`/rex-oracle`**: Rex, teerex the utility, rexconfig, hive's Rex setup and the M5's Rex app.
   - **`/rivet-oracle`**: Rivet's engine under the hood; never a project's items.
   An oracle maintains its layer; project work belongs to a seat.

## Words

- **Machine**: one of the names above. **Host** means the same.
- **Pane / block**: one terminal in Rex. **Tab / window**: a Rex tab.
- **Seat**: the agent that took `/seat`; agents message it directly. **Oracle**: an agent holding one of
  the three layer roles.
- **Item**: a piece of Rivet work (a discovery or a task). **Promote**: turning a discovery's
  candidate tasks into tasks. **Ship stop**: where finished work waits for the operator's QA.
- **Project**: a folder of inputs Rivet reads (`~/rivet/projects/<name>`).
- **agent-core**: this repo, the source of every instruction every agent loads. Changed here,
  pushed, then `git -C ~/agent-core pull` on each machine; a post-merge hook writes each harness's instructions.
