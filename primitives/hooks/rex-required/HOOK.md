---
name: rex-required
description: Refuses any agent that is not running in a Rex pane, and sends Rex terminal reads through teerex once teerex can reach the server.
---

# Rex Required

Rex is the control plane for every agent on every machine (Josh, 2026-11-12). An agent outside a
Rex pane is an agent the operator cannot see, address or return to.

**Events:** the agent's launch, and before every tool call.

**Inside Rex means:** the process carries a Rex pane address, either `REX_SESSION` and `REX_BLOCK`
(a local Rex pane) or `LC_REX_SESSION` and `LC_REX_BLOCK` (a shell reached over ssh from a Rex
pane), or `LC_AGENT_REPORT_TO` naming a Rex block (an agent started by `agent-spawn`, which only
opens Rex tabs).

**Launching is one word (Josh, 2026-11-12: "I do not want to have to remember a shitload of flags").**
Typing an agent's name (`claude`, `codex`, `pi`) is the whole launch. The shell wrapper adds that
agent's standing flags (claude: `--dangerously-skip-permissions`; codex:
`--dangerously-bypass-approvals-and-sandbox`, its yolo mode), and from a shell outside Rex it
opens the same command in a new Rex tab instead of refusing.

**Refuses:**

- launching an agent from a shell outside Rex when no Rex tab can be opened;
- every tool call of an agent that is not inside Rex, so an agent started some other way does no
  work;
- an in-process subagent (Claude Code's `Agent`, `Task` and `Workflow` tools): every agent gets its own
  Rex tab, started with `agent-spawn`;
- a shell command that reads a Rex terminal with `rex capture`, when the
  [teerex](../../tools/teerex/TOOL.md) tool is installed and its read-only observation of this
  pane succeeds. While teerex cannot reach the server (an unsupported Rex API revision, a machine
  it does not run on), `rex capture` is allowed.

**The refusal says:** how to start the same agent in a Rex pane (`rex run -- <agent> ...`), or the
exact `teerex observe` / `teerex watch` command to use instead of `rex capture`.

**When it cannot tell:** the guard's own failure (a missing `jq`, unreadable input) allows. It
refuses only on a positive finding, never because of its own bug.

**Off switch:** remove the hook entry or the launch wrapper. There is no per-call override.

**No worker exception.** Josh, 2026-11-12: "If it runs on my machine, I'm running it through
Rex. No ifs, no ands, no buts." Engine workers (Rivet, `MW_WORKER=1`) are agents and run in Rex
tabs like any other. This guard overrides the [worker exception](../../rules/worker-guards/RULE.md).

`scripts/` holds the reference implementation:

- `rex-required`: `check` (exit 0 inside Rex), and `hook claude|codex|cursor` (before-tool guard
  reading the harness's JSON on stdin).
- `rex-required.zsh`: wraps every agent command in an interactive zsh so a launch outside Rex is
  refused before the agent starts. Source it last in `~/.zshrc`.
- `pi-rex-required.ts`: the same before-tool guard as a pi extension.
