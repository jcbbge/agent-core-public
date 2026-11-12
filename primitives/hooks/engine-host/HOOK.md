---
name: engine-host
description: Refuses any agent that is not running on hive, the machine the Rivet engine runs on, whatever app is its window. Sends Rex terminal reads through teerex once teerex can reach the server.
---

# Engine Host

Every agent runs on hive, where the Rivet engine is (Josh, 2026-11-12: "rather than the rex
enforcement, i want the vps rivet engine enforcement"). The app an agent appears in is only its
window: Rex, T3 Code, Claude Desktop, a plain terminal. The window may be on any machine; the
agent's process is on hive. This replaces the earlier rule that every agent runs in a Rex pane.

**Events:** the agent's launch, and before every tool call.

**On hive means:** the kernel hostname is the engine host's (`ENGINE_HOST`, default
`optimistic-wiles.hivelocitydns.com`). Rivet's sandboxed workers share that hostname, so they pass.

**Launching is one word (Josh, 2026-11-12: "I do not want to have to remember a shitload of flags").**
Typing an agent's name (`claude`, `codex`, `pi`) is the whole launch. On hive the shell wrapper
adds that agent's standing flags (claude: `--dangerously-skip-permissions`; codex:
`--dangerously-bypass-approvals-and-sandbox`). On any other machine it opens the same command on
hive over ssh in the same terminal, starting in hive's home, instead of refusing.

**Refuses:**

- every tool call of an agent that is not on hive, so an agent started some other way does no work;
- an in-process subagent (Claude Code's `Agent`, `Task` and `Workflow` tools): every agent is
  visible as its own session, started with `agent-spawn`;
- a shell command that reads a Rex terminal with `rex capture`, when the
  [teerex](../../tools/teerex/TOOL.md) tool is installed and its read-only observation of this
  pane succeeds. While teerex cannot reach the server, `rex capture` is allowed.

**Does not refuse:** an agent outside a Rex pane. An agent an app such as T3 Code starts on hive
passes.

**The refusal says:** how to start the same agent on hive, or the exact `teerex observe` /
`teerex watch` command to use instead of `rex capture`.

**When it cannot tell:** the guard's own failure (a missing `jq`, unreadable input) allows. It
refuses only on a positive finding, never because of its own bug.

**Off switch:** remove the hook entry or the launch wrapper. There is no per-call override.

**No worker exception.** Engine workers run on hive like any other agent. This guard overrides the
[worker exception](../../rules/worker-guards/RULE.md).

`scripts/` holds the reference implementation:

- `engine-host`: `check` (exit 0 on hive), and `hook claude|codex|cursor` (before-tool guard
  reading the harness's JSON on stdin).
- `engine-host.zsh`: wraps every agent command in an interactive zsh: standing flags on hive,
  opens on hive anywhere else. Source it last in `~/.zshrc`.
- `pi-engine-host.ts`: the same before-tool guard as a pi extension.
