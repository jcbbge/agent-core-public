---
name: teerex
description: Guarded input for Rex panes. Send checks the draft and reports input acknowledgments. Clutch manages cooperative holds and pending messages.
---

# teerex

Run `teerex --help` on hive for `send` and `clutch`. The socket comes from
`REX_SERVER`, the local runtime path, or an explicit `--socket` argument.

`send` checks for an existing draft or hold. Its receipt reports the queue ID or
the Rex paste and Enter acknowledgments. rexconfig's `agent-send` applies
messaging and seat rules and verifies receipt by the receiving harness.

`clutch take`, `release`, `status`, `queue` and `drain` manage cooperative
holds and pending deliveries. Read `teerex clutch --help` for details.

The pinned hive build is managed by `~/rexconfig/bin/install-teerex-build`.
`teerex --version` reports its build ID. The installer activates it through
`~/.local/opt/teerex-managed/current` and retains earlier versions.

[teerex usage](https://github.com/jcbbge/teerex/blob/main/docs/usage.md)
