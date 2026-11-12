---
name: teerex
description: Rex extensions CLI (jcbbge/teerex) - bounded, attributed reads of a Rex terminal (observe), offline comparison of two reads (compare), a foreground wait for a change or a status report (watch), and a supervised local run with exit evidence (run). Use instead of `rex capture` and sleep-poll loops whenever an agent reads or waits on a Rex pane.
---

# teerex

Source and releases: https://github.com/jcbbge/teerex. On PATH as `teerex`.

**Present when:** `teerex observe` of the caller's own pane exits 0. `teerex --help` answering is
not enough: the binary refuses a Rex server whose API revision it does not support.

**Install (Apple-silicon Mac, no sudo):** download the release tarball and `SHA256SUMS` into
`~/.local/opt/teerex/<version>/`, verify with `shasum -a 256 -c SHA256SUMS`, extract, and link
`~/.local/bin/teerex` to that version's `teerex`. Upgrade = new version folder, move the link.
Remove = delete the link and the folder. It changes no Rex configuration and starts no service.

**Compatibility (v0.1.0-alpha.1):** macOS only (observe/watch); tested against Rex 0.1.0-preview.16,
API revision 13. An older server returns `unsupported Rex API revision`.

The [engine-host](../../hooks/engine-host/HOOK.md) guard sends `rex capture` here once teerex
is present. How to use it lives in the `rex` skill.
