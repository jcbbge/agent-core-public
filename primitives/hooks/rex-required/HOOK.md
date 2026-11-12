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
pane).

**Refuses:**

- launching an agent from a shell that is not inside Rex;
- every tool call of an agent that is not inside Rex, so an agent started some other way does no
  work;
- a shell command that reads a Rex terminal with `rex capture`, when the
  [teerex](../../tools/teerex/TOOL.md) tool is installed and its read-only observation of this
  pane succeeds. While teerex cannot reach the server (an unsupported Rex API revision, a machine
  it does not run on), `rex capture` is allowed.

**The refusal says:** how to start the same agent in a Rex pane (`rex run -- <agent> ...`), or the
exact `teerex observe` / `teerex watch` command to use instead of `rex capture`.

**When it cannot tell:** the guard's own failure (a missing `jq`, unreadable input) allows. It
refuses only on a positive finding, never because of its own bug.

**Off switch:** remove the hook entry or the launch wrapper. There is no per-call override.

Refusal enforcement follows the [worker exception](../../rules/worker-guards/RULE.md): `MW_WORKER=1`
passes silently, checked before anything else.

`scripts/` holds the reference implementation:

- `rex-required`: `check` (exit 0 inside Rex), and `hook claude|codex|cursor` (before-tool guard
  reading the harness's JSON on stdin).
- `rex-required.zsh`: wraps every agent command in an interactive zsh so a launch outside Rex is
  refused before the agent starts. Source it last in `~/.zshrc`.
- `pi-rex-required.ts`: the same before-tool guard as a pi extension.
