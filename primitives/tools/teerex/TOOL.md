---
name: teerex
description: Rex extensions CLI (jcbbge/teerex) - bounded pane reads and waits (observe, watch, compare, filter), supervised runs (run, offstage), visible agents and messages (spawn, send, agents, jobs), and the alpha.5 operating layer (surfaces, boards with the seat inbox and decision cards, recovery snapshot/restore and update impact, named hosts and fleet install). Use instead of `rex capture`, sleep-poll loops and hand-written restart scripts.
---

# teerex

Source and releases: https://github.com/jcbbge/teerex. A utility CLI on top of Rex, never an agent.
On PATH as `teerex`. How to use each command lives in the [`rex` skill](../../skills/rex/SKILL.md).

**Installed:** v0.1.0-alpha.5 on m5 (Apple silicon) and hive (Linux x86_64), managed root
`~/.local/opt/teerex-managed` (`current` → `versions/<tag>`); alpha.4 retained for rollback.

**Present when:** `teerex --version` prints the expected tag **and** `teerex observe` of the
caller's own pane exits 0. Help answering is not enough: the binary refuses a Rex server whose API
revision it does not support.

**Install / upgrade (no sudo, both machines):** take `tools/install/teerex-install` from the
release's `onboarding` archive, then

```sh
bash teerex-install upgrade --version v0.1.0-alpha.N --prefix ~/.local/opt/teerex-managed
bash teerex-install list    --prefix ~/.local/opt/teerex-managed     # Active: the new tag
bash teerex-install verify  --prefix ~/.local/opt/teerex-managed --version v0.1.0-alpha.N
```

It downloads and checks `SHA256SUMS` itself (`--from DIR` for pre-downloaded assets), keeps the
previous version, and changes no PATH, shell profile, Rex configuration or running program.
Rollback: `teerex-install rollback --version <old tag>`. Read the release notes before upgrading:
`gh release view <tag> -R jcbbge/teerex`. Once a hosts config exists,
`teerex fleet install --config <hosts.json> --host <name> --version <tag>` plans the install on a
named machine and `--apply` performs it (no hosts config is set up yet).

**Compatibility (alpha.5):** Rex integer API 10–13; `jobs`, `boards`, `agents` and `recovery
snapshot/restore` need API 13 (both machines run API 13). `run`, `doctor` and `offstage` are
Mac-only. The operating-layer commands (`surfaces`, `boards`, `agents`, `recovery`, `targets`,
fleet) need Python 3.9+.

**Open gaps (jcbbge/teerex issues):** hive cannot read panes hosted on the m5 (#10); no draft
recovery, harness resume-ID discovery or Rex server updater; `agents` hooks are untested against
the real paid harnesses. Gaps are filed as issues for the builder, never worked around.

The [engine-host](../../hooks/engine-host/HOOK.md) guard sends `rex capture` here once teerex
is present.
