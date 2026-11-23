---
name: teerex
description: Rex extensions CLI for bounded pane reads and waits (observe, watch, compare), guarded sends and cooperative holds (send, clutch), pane operations (surfaces), private evidence (records), and recovery. Named hosts and fleet installation support the CLI. Rexconfig owns agent lifecycle and the work board.
---

# teerex

Source and releases: https://github.com/jcbbge/teerex. A utility CLI on top of Rex, never an agent.
On PATH as `teerex`. How to use each command lives in the [`rex` skill](../../skills/rex/SKILL.md).

**Installed:** the build pinned in `~/rexconfig/teerex.version`, on hive only (Linux x86_64; the M5 runs only the Rex app), managed root
`~/.local/opt/teerex-managed` (`current` → `versions/<build>`).
`teerex --version` and `readlink` of `current` say which; earlier builds stay under `versions/` for rollback.

**Present when:** `teerex --version` prints the expected tag **and** `teerex observe` of the
caller's own pane exits 0. Help answering is not enough: the binary refuses a Rex server whose API
revision it does not support.

**Install on hive:** follow the [rexconfig build and install procedure](https://github.com/jcbbge/rexconfig#readme).
`~/rexconfig/bin/install-teerex-build` builds the pinned commit and activates the verified managed release.
`teerex fleet rollback --config ~/.config/teerex/hosts.json --host hive --version <retained tag>`
prints the rollback plan. Add `--apply` to perform it.

Check the selected command’s help for its Rex API requirements. Targets, recovery, records and
fleet use Python 3.9 or later.

**Draft protection:** `teerex send` guards and restores operator drafts by default; agent-core
does not maintain a second parser or restore loop. Read `teerex send --help` for its heuristic
and race limits.

**Open gaps:** restart-time draft recovery, harness resume-ID discovery and a Rex server updater
are distinct from send-time draft protection. Check the installed command help and the teerex
issue tracker before assuming a feature exists. Gaps are filed for the builder, never worked around.

The [engine-host](../../hooks/engine-host/HOOK.md) guard sends `rex capture` here once teerex
is present.
