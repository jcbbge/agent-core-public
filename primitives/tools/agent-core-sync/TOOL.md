---
name: agent-core-sync
description: Writes the Rex/Rivet connection map into harness entrypoints and retires agent-core-owned process links.
---

# agent-core-sync

`agent-core-sync` is installed on PATH from `scripts/`. `--check` reports drift without writing. It generates the always-loaded `CLAUDE.md` and `AGENTS.md` files from the global and estate connection maps for installed harnesses on this host. It removes only links into this repo's retired rule, command and skill directories, plus Codex command copies marked as owned by agent-core. It does not touch foreign settings, other hooks or unowned files.

Run on hive and M5 after publishing changes; the repo's post-merge hook also invokes it. No work process or skill bundle is installed by default.
