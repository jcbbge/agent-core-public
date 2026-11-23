---
name: engine-host
description: Agents should run on hive, where the Rivet engine is, whatever app is their window. A suggestion, never a refusal; on a Mac, typing an agent name opens it on hive. Also refuses sub-agents that work outside the system and guards Rex terminal reads.
---

# Engine Host

Agents should run on hive, where the Rivet engine is (Josh, 2026-11-12: "rather than the rex
enforcement, i want the vps rivet engine enforcement"). The app an agent appears in is only its
window: Rex, T3 Code, Claude Desktop, a plain terminal. The window may be on any machine; the
agent's process is on hive. This replaces the earlier rule that every agent runs in a Rex pane.

**Event:** before every tool call.

**On hive means:** the kernel hostname is the engine host's (`ENGINE_HOST`, default
`optimistic-wiles.hivelocitydns.com`). Rivet's sandboxed workers share that hostname, so they pass.

**Launching is `rex <agent>` (Josh, 2026-11-12: "I do not want to have to remember a shitload of flags";
2026-11-15: "i want 'rex [agent]' to be the command").** `rex claude`, `rex codex`, `rex pi` run rexconfig's
`agent-open`: the harness with its standing flags (rexconfig `agent/harness.json`) without a brief, starter or role: on
hive in the terminal it was typed in, from another machine in a visible labelled tab on hive. Rexconfig owns the `rex` wrapper.
Agent-core ships no launch wrapper.

**Refuses:**

- a harness sub-agent (Claude Code's `Agent`, `Task` and `Workflow` tools) whose brief does not put it
  in the system. Allowed (Josh, 2026-11-23: the rule was against agents outside the system, not the
  mechanism) when the brief names the task it picks up (`Task: <key>`) and the contractor rulebook
  (`~/rivet/CONTRACTOR.md`); a `web-fetch` page read is a tool and passes. The brief check is a gate,
  not proof: the rulebook binds the sub-agent to NQ on the task, the task's streams and Rex;
- `rex capture`, `rex block capture` and `agent-read` in command position when the target
  is an agent's pane or cannot be identified. Use `rex block capture -s SESSION -b BLOCK` with
  the IDs Rex returned for an ordinary command pane you started. The guard checks Rex's block,
  Program Status and process metadata and the local agent identity registry. It checks the
  kind of program in the pane. The agent contract limits capture to panes you started.
  Quoted text mentioning a command does not count.

- a shell command that pauses a process: `kill`, `pkill` or `killall` in command position with a
  stop signal (`-STOP`, `-SIGSTOP`, `-19`, `-TSTP`, `-SIGTSTP`, `-20`, `-s STOP`, `--signal=STOP`).
  Agents are never paused (Josh, 2026-11-20); a paused agent reads nothing and its messages pile up
  unseen. Quoted text that mentions these never matches. Workers (`MW_WORKER=1`) pass.

**Does not refuse:** a message, commit message or any quoted text that mentions the capture
command; an agent on any machine, in or outside a Rex pane (Josh, 2026-11-12: "This is a suggested. It's not authoritative."). An agent an app such as T3 Code starts on hive
passes.

**The refusal says:** the exact `start-work` command; or, instead of `rex capture`, the agent's
Program Status record (`rex do com.superlogical.terminal.program_status -b <block>`), `rex wait` for a
command, and `rex block capture` for output of an ordinary command pane the agent started.

**When it cannot tell:** the guard's own failure (a missing `jq`, unreadable input) allows. It
treats a recognized screen read with unavailable target metadata as unidentified.

**Off switch:** remove the hook entry. There is no per-call override.

**No worker exception.** The subagent and screen-read refusals apply to engine workers too. This guard overrides the
[worker exception](../../rules/worker-guards/RULE.md).

`scripts/` holds the reference implementation:

- `engine-host`: `check` (exit 0 on hive), and `hook claude|codex|cursor` (before-tool guard
  reading the harness's JSON on stdin).
- `pi-engine-host.ts`: the same before-tool guard as a pi extension.
