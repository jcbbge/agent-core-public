---
name: ground
description: Refuses an agent's first change in a repository until it has read the repository.
---

# ground — look before you cut

A jig. A jig makes the wrong cut impossible, so nothing
has to be re-checked afterwards. It checks shape, not content: *did you look*, never
*is your code right*.

| File | What |
|---|---|
| `ground` | `check` (exit 2 plus a refusal when not grounded), `brief`, `status` and `bash-writes` |

## The rule

An agent's first change in a git repo is refused until the spine (tool `spine`) shows
that this agent, in this session:

1. read the repo's entrypoint: the repo's own instruction file (`AGENTS.md`, `README.md`, or the file the harness loads).
   The file the harness loads by itself for its own working directory counts.
2. read one thing from each ground the repo itself shows it has: its contracts (specs,
   decisions, `docs/`, the package manifest), its API (openapi, proto, graphql,
   routes) and its database schema (schema files, migrations, prisma, drizzle).
   These are found with `git ls-files`. Nothing is configured, and nothing is ever
   written into a repo.
3. surveyed the code: at least `GROUND_MIN_READS` (3) reads or searches in the repo.

The refusal lists exactly what is still missing. Every session is handed the same list
at its start, so a well-behaved agent never meets the stop.

A Bash command that writes (`sed -i`, `>`, `tee`, `mv`, `cp`, `rm`, `git commit`, ...)
counts as a write. Once an agent passes, it stays passed for that repo for the rest of
the session. Sub-agents ground for themselves.

These are never gated: paths outside any git repo, `TASKS.md`, anything under `.git/`.

## Wiring

On the **before-tool** event (the hook events in the distro README) for edits, writes and shell
commands, run `ground check`; exit 2 means refuse and show its output to the agent. The
reads it counts come from the spine (tool `spine`), so the spine must be wired too.

Everything fails open on a script error. `GROUND_GATE=off` disables the gate; the worker exception also applies.

The `check` command follows the [worker exception](../../rules/worker-guards/RULE.md)
before configuration and state initialization. Workers still ground before changes.
Other commands retain their behavior.
