---
name: rex
description: Rex is the terminal control plane on the M5 and on hive - sessions, tabs, panes, running and reading terminals, controlling Rex apps - plus teerex, the Rex extensions CLI - bounded reads and waits, supervised runs, visible agents and messages, panes it opens/moves/closes, the fleet board, restart snapshot/restore, named hosts. Use for any Rex task, any time an agent starts, reads, waits on or talks to another pane, lays out work across machines, or before a Rex restart.
---

# Rex

Read the installed Rex guide with `rex __internal skill`, then read the
[teerex agent guide](https://github.com/jcbbge/teerex/blob/main/docs/agents.md).
The source on hive is `~/teerex/docs/agents.md`; from another machine read it with
`ssh hive cat /home/jrg/teerex/docs/agents.md`. Do not duplicate its command recipes here.
Also read the [teerex README](https://github.com/jcbbge/teerex/blob/main/README.md).
Check `teerex COMMAND --help` for the installed interface.

Estate policy:

- Agents should run on hive. A Rex pane is not required; the [engine-host guard](../../hooks/engine-host/HOOK.md)
  refuses in-process subagents and directs terminal reads through teerex.
- Every pane, read, wait, run, launch, message and board goes through Rex and teerex.
  Missing functionality belongs in a jcbbge/teerex issue; never build plumbing beside them.
- Start agents visibly with `agent-spawn --brief-file brief.md SESSION NAME -- claude|codex|pi`.
  Follow the [messaging rule](../../rules/agent-messaging/RULE.md). Your report is your last message;
  do not send it a second time. Launches run independently.
- Keep your working list in your teerex scratchpad (`teerex scratch todo|now|done|flag`), as the
  global directive's working-list contract says. Reap what you spawn: `teerex agents accept`, then
  close each worker's pane by the exact block id in its launch receipt (`teerex surfaces close`); its
  scratchpad viewer follows. Recipes: teerex `docs/agents.md` (Accept reports and reap workers).
- Find the seat with `teerex --config ~/.config/teerex/hosts.json --host hive seat resolve`.
- Questions for Josh go directly to the seat. Native `teerex ask` types a complete decision card
  through guarded send; it does not need an inbox. Use `teerex ask --help` for card and resolution flags.
- Messaging wrappers select `TEEREX_HOST` (default `hive`) and `TEEREX_HOSTS`
  (default `~/.config/teerex/hosts.json`). Choose `m5` explicitly for M5 panes; no host search or fallback.
- Rexconfig (`~/rexconfig`, its README and `./install --check`) owns Rex configuration, named hosts,
  profiles and `~/.config/teerex/shell.zsh`. Native human launch functions apply standing flags;
  the Mac profile route opens compute on hive. Agent-core-sync does not install that configuration.
- Never restart Rex or kill Rex processes without Josh's yes. Before a restart, use native recovery
  impact/snapshot commands and record missing resume commands or unsent drafts. Never rename a shared session.
- Long output for Josh lives in a Markdown document; the seat opens it for him as a floating `leaf` layer
  (agent-messaging rule, item 8). Other agents send the seat the path.
  Close only the panes you provisioned when the work lands.

`teerex boards calls --once --json --limit N` reads the native call log without message bodies.
Read its `--help` for cross-host selection. Cartridge management, doctor, surfaces, jobs, watches,
visible runs and recovery are documented in the upstream guide rather than copied here.

| Command | Use | Example |
|---|---|---|
| `cartridges` | List, preview, install, run or remove the separately packaged native payloads. Plan first; `--apply` mutates; `run` holds the in-use lease (calling a payload directly does not). | `teerex cartridges install --all --catalog "$CATALOG" --allow-experimental` |

Prefer ready cartridges: `teerex cartridges install --all --catalog "$CATALOG"` installs only evidence-ready items; `compatibility.readiness` names the proving record.

`seat` uses native server-wide ensure; it has no private pointer or lock. Its creation session is
`SEAT_SESSION` (default `rivet`) on hive. `agent-read` returns native `observe --state` JSON, including evidence lines and unknowns; use `observe --tail` when you need newest raw text.

**Records.** When a check result, open question or handoff must outlive your turn, write it with `teerex records` in `~/.local/state/teerex-records` (once: `teerex records init --store ~/.local/state/teerex-records`). Put private text in a JSON `--fields-file -` rather than flags. **Before you stop on unfinished work, park:** `teerex records park --store … --host <host> --socket <socket> --session "$REX_SESSION" --block "$REX_BLOCK" --writer <your name> --fields-file -` with `question` and `next_action {actor, step, stop_when}`. Attach every teerex receipt that matters: `teerex records attach --id <id> --by <you> --evidence <packet.json> --check-command "<argv>" --assertion passed|failed|unknown --establishes "…" --does-not-establish "…"`. Never infer the assertion from exit 0. Record skipped checks with `records add omission` and leftovers with `records add cleanup`. In a decision card's `context`, add `records: teerex records resume --id <id>`. Run `records lint --id <id>` before reporting and name the id in your report. To pick work up, run `teerex records resume --id <id>` first; use `records navigate --focus yes` only if you need the pane.

**Decisions.** When you settle a decision that someone could later reasonably reopen, record it with `teerex records new --kind decision` in `~/.local/state/teerex-records`. Include the claims it rests on (`--depends-on` pins for each version, ref or issue state they assume), at least one rejected option with `revisit_when`, and an invalidator. Before acting on an older decision, run `records revalidate --id <id>`. If it says `needs_review`, report that instead of acting on it. Never reopen a rejected option whose condition has not changed; ask the seat if you think it should be.
