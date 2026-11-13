---
name: rex
description: Rex is the terminal control plane on the M5 and on hive - sessions, tabs, panes, running and reading terminals, controlling Rex apps - plus teerex (alpha.5), the Rex extensions CLI - bounded reads and waits, supervised runs, visible agents and messages, panes it opens/moves/closes, the fleet board, restart snapshot/restore, named hosts. Use for any Rex task, any time an agent starts, reads, waits on or talks to another pane, lays out work across machines, or before a Rex restart.
---

# Rex

Read the installed Rex guide with `rex __internal skill`, then read the
[teerex agent guide](https://github.com/jcbbge/teerex/blob/main/docs/agents.md).
The source on hive is `~/teerex/docs/agents.md`; from another machine read it with
`ssh hive cat /home/jrg/teerex/docs/agents.md`. Do not duplicate its command recipes here.
Check `teerex COMMAND --help` for the installed interface.

Estate policy:

- Agents should run on hive. A Rex pane is not required; the [engine-host guard](../../hooks/engine-host/HOOK.md)
  refuses in-process subagents and directs terminal reads through teerex.
- Every pane, read, wait, run, launch, message and board goes through Rex and teerex.
  Missing functionality belongs in a jcbbge/teerex issue; never build plumbing beside them.
- Start agents visibly with `agent-spawn --brief-file brief.md SESSION NAME -- claude|codex|pi`.
  Follow the [messaging rule](../../rules/agent-messaging/RULE.md). Your report is your last message;
  do not send it a second time. Concurrent launches queue.
- Questions for Josh go directly to the seat. Native `teerex ask` types a complete decision card
  through guarded send; it does not need an inbox. Use `teerex ask --help` for card and resolution flags.
- Messaging wrappers select `TEEREX_HOST` (default `hive`) and `TEEREX_HOSTS`
  (default `~/.config/teerex/hosts.json`). Choose `m5` explicitly for M5 panes; no host search or fallback.
- Rexconfig (`~/rexconfig`, its README and `./install --check`) owns Rex configuration, named hosts,
  profiles and `~/.config/teerex/shell.zsh`. Native human launch functions apply standing flags;
  the Mac profile route opens compute on hive. Agent-core-sync does not install that configuration.
- Never restart Rex or kill Rex processes without Josh's yes. Before a restart, use native recovery
  impact/snapshot commands and record missing resume commands or unsent drafts. Never rename a shared session.
- Long output for Josh lives in a Markdown document opened in `leaf` beside the agent.
  Close only the panes you provisioned when the work lands.

`teerex boards calls --once --json --limit N` reads the native call log without message bodies.
Read its `--help` for cross-host selection. Cartridge management, doctor, surfaces, jobs, watches,
visible runs and recovery are documented in the upstream guide rather than copied here.

| Command | Use | Example |
|---|---|---|
| `cartridges` | List, preview, install, run or remove the separately packaged native payloads. Plan first; `--apply` mutates; `run` holds the in-use lease (calling a payload directly does not). | `teerex cartridges install --all --catalog "$CATALOG" --allow-experimental` |

`seat` uses native server-wide ensure; it has no private pointer or lock. Its creation session is
`SEAT_SESSION` (default `rivet`) on hive. `agent-read` selects native `observe --tail` for newest output.
