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
  forwards: Rivet engine at the M5's 127.0.0.1:6420, the M5's Chrome to hive's 127.0.0.1:9222.
- Rex reaches hive's Rex server natively: the M5's Rex host `hive` is
  `ssh://jrg@hive/run/user/1000/rex/server.sock` (`rex -S hive ...`). teerex reaches both machines
  through its named-host config on the M5, `~/.config/teerex/hosts.json`
  (`teerex --config <it> --host hive ...`). No hand-built socket forward.
- Connections are shared (ControlMaster): a second `ssh <name> <cmd>` costs under 0.1 s. Call it
  as often as the work needs.
- **Finder view, on the M5 (being set up):** `~/Machines/hive` (hive's home) and `~/Machines/m1`
  (the M1's home) are the other machines' files. They are a view for the operator, not a second copy: an agent
  works on a file where it lives, over ssh.

## Where things live (one place each)

- Rex and teerex configuration: `~/rexconfig` on hive and m5; install with its `./install`.
  Rex reads `~/.config/rex/init.lua`; teerex named hosts read `~/.config/teerex/hosts.json`.

- Code, checkouts, Rivet, work items, agent sessions: **hive**.
- Anything the operator looks at (Rex windows, Chrome, Finder): **m5**.
- A file never gets copied between machines to work on it. Read and write it where it lives.
  Copy only to hand it to a tool that cannot reach it (then say so).

## The layers of control

From the ground up. Each layer only drives the one above it.

1. **Machine.** The OS, its services (launchd on a Mac, systemd `--user` on hive), PATH, ssh.
2. **Rex.** The terminal control plane, and one window onto agents among others. The Rex app
   runs on the m5; a Rex server runs on each machine (hive: `~/opt/rex/bin/rex`, `rex.service`).
   A pane's address is its session and block (`REX_SESSION`, `REX_BLOCK`; over ssh,
   `LC_REX_SESSION`, `LC_REX_BLOCK`).
3. **teerex.** The Rex extensions CLI: bounded reads and waits, supervised runs, visible agents and
   messages, and the operating layer (panes, fleet board, restart snapshot/restore, named
   hosts). Every agent uses it for everything it does, and nothing is hand-built beside it; how is
   in the `rex` skill. Installed: v0.1.0-alpha.5 on m5 and hive (`~/.local/opt/teerex-managed`,
   alpha.4 retained). Both Rex servers are API 13. Named-host commands reach M5 panes from hive:
   `teerex --config ~/.config/teerex/hosts.json --host m5 observe ...`.
   Configuration and installation belong to `~/rexconfig`; see its README and `./install --check`.
4. **Rivet.** The engine on hive (127.0.0.1:6420, `rivet-node.service`, CLI `rv`). It drives work
   items through discovery, planning, implementation, tests, audit and the ship stop. Projects
   are inputs from `~/rivet/projects/<name>/`; the engine names no project.
5. **Agents.** Claude, Codex, pi and the rest, any model. **Agents should run on hive**, whatever
   app is their window (Rex, T3 Code, Claude Desktop, a terminal on any machine). This is a
   suggestion, not a block: nothing refuses an agent for the machine it is on. An agent is started
   by typing its name (`claude`, `codex`, `pi`): native `teerex agents human` applies profile
   standing flags and opens a tracked visible tab; rexconfig owns the Mac route to hive. Agents talk with
   `agent-send` / `agent-spawn` / `agent-ask`.
6. **The seat.** The one agent the operator types to, his concierge for the session. He starts it
   by typing `seat` in any Rex tab (Mac or hive); if a seat is already running, `seat` switches to
   it instead. Its Rex tab is named "seat". Agents message it directly with `agent-send`, typed into
   its pane; questions for the operator go there as decision cards. Its brief is `tools/agent-messaging/SEAT.md`.

## Words

- **Machine**: one of the names above. **Host** means the same.
- **Pane / block**: one terminal in Rex. **Tab / window**: a Rex tab.
- **Seat**: the agent the operator talks to; agents message it directly.
- **Item**: a piece of Rivet work (a discovery or a task). **Promote**: turning a discovery's
  candidate tasks into tasks. **Ship stop**: where finished work waits for the operator's QA.
- **Project**: a folder of inputs Rivet reads (`~/rivet/projects/<name>`).
- **agent-core**: this repo, the source of every instruction every agent loads. Changed here,
  pushed, then `agent-core-sync` on each machine.
