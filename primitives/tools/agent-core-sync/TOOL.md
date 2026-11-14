---
name: agent-core-sync
description: Brings this machine's agents up to date with agent-core - pulls the repo, writes every installed harness's always-loaded instructions from the global and estate directives, and links the rules. Run it on each machine after an agent-core change lands.
---

# agent-core-sync

`agent-core-sync` (on PATH from `scripts/`). Safe to run again; it changes only what agent-core owns.

**Present when:** `agent-core-sync --check` exits 0, meaning every installed harness's entrypoint
matches what agent-core would write.

What it makes true on the machine it runs on:

- agent-core is at the latest pushed `main` (fast-forward only; a dirty or diverged checkout is
  reported, never reset).
- Each installed harness's always-loaded file is exactly the global directive followed by the
  estate directive, with a header saying it is generated: Claude Code `~/.claude/CLAUDE.md`, Codex
  `~/.codex/AGENTS.md`, pi `~/.pi/agent/AGENTS.md`, opencode `~/.config/opencode/AGENTS.md`, Gemini
  `~/.gemini/GEMINI.md`. A harness counts as installed when its folder exists.
- `~/.claude/rules/<name>.md` links to every `primitives/rules/<name>/RULE.md`.

Never edit a generated file. Change agent-core and push; then `git -C ~/agent-core pull` on each
machine (hive and m5) runs it through the post-merge hook. `agent-core-sync` by hand does the same.

Only Claude Code gets the rules linked; every other harness is told by the global directive to read
`~/agent-core/primitives/rules/<name>/RULE.md` itself.
