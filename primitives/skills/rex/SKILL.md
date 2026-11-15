---
name: rex
description: Rex is the terminal control plane on the M5 and on hive - sessions, tabs, panes, running and reading terminals, controlling Rex apps - plus teerex, the Rex extensions CLI - bounded reads and waits, supervised runs, safe sends into a pane, panes it opens/moves/closes, the board, restart snapshot/restore, named hosts. Use for any Rex task, any time an agent starts, reads, waits on or talks to another pane, lays out work across machines, or before a Rex restart.
---

# Rex

Read the installed Rex guide with `rex __internal skill`, then the
[teerex README](https://github.com/jcbbge/teerex/blob/main/README.md) for reads, waits, sends and panes.
Agent commands (starting agents, lists, hooks, the seat) are rexconfig's: `~/rexconfig/README.md`
(Agent commands) and the [messaging rule](../../rules/agent-messaging/RULE.md).
Check `teerex COMMAND --help` for the installed interface.

Estate policy:

- Agents should run on hive. A Rex pane is not required; the [engine-host guard](../../hooks/engine-host/HOOK.md)
  refuses in-process subagents and directs terminal reads through teerex.
- Every pane, read, wait, run, message and board goes through Rex and teerex; agent launch, lists,
  hooks and the seat go through rexconfig's commands. Missing functionality belongs in a
  jcbbge/teerex or jcbbge/rexconfig issue; never build plumbing beside them.
- Start agents visibly with `agent-spawn --brief-file brief.md SESSION NAME -- claude|codex|pi`.
  Follow the [messaging rule](../../rules/agent-messaging/RULE.md). Your report is your last message;
  do not send it a second time. Launches run independently.
- Keep your working list with `scratch todo|now|done|flag`, as the global directive's working-list
  contract says. Reap what you spawn: answer the worker's report, then `agent-close <session> <pane>`
  with the pane id `agent-spawn` printed; its scratchpad viewer follows.
- The seat is the pane labelled `seat`: `agent-send seat <your name> ...`.
- Close only panes you opened (a written rule); `agent-close` refuses the seat, tasks and board panes.
- Machine check: `teerex doctor --all --config ~/.config/teerex/hosts.json` (both machines: build vs pin, Rex server, a guarded pane round trip, rexconfig, harness hooks).
- Questions for Josh go directly to the seat. `agent-ask` sends a complete decision card through
  agent-send; `agent-ask --help` lists its fields.
- Messaging wrappers select `TEEREX_HOST` (default `hive`) and `TEEREX_HOSTS`
  (default `~/.config/teerex/hosts.json`). Choose `m5` explicitly for M5 panes (send, read, open); agents themselves always run on hive. No host search or fallback.
- Rexconfig (`~/rexconfig`, its README and `./install --check`) owns Rex configuration, named hosts,
  the agent commands and the `rex` wrapper: `rex claude|codex|pi` opens that agent clean on hive with
  its standing flags, from either machine; any other `rex ...` is the real Rex. Agent-core-sync does not install that configuration.
- Never restart Rex or kill Rex processes without Josh's yes. Before a restart, use native recovery
  impact/snapshot commands and record missing resume commands or unsent drafts. Never rename a shared session.
- Long output for Josh lives in a Markdown document; the seat opens it for him as a floating `leaf` layer
  (agent-messaging rule, item 8). Other agents send the seat the path.
  Close only the panes you provisioned when the work lands.

Doctor, surfaces, jobs, watches, visible runs, the board and recovery are documented in the
upstream guide rather than copied here.

**Extending Rex** (a key, action, view, watcher, harness extension or someone else's plugin): read
[references/ecosystem.md](references/ecosystem.md) first; rexconfig is the only writer of Rex's config.
A view or dashboard in a pane is an applet: the [rex-applet skill](../rex-applet/SKILL.md).

The seat and the oracles are roles: `/seat` etc. run `agent-role <role>`, which labels the pane; there is
no `seat` launcher, pointer or lock. `agent-read` returns native `observe --state` JSON, including evidence lines and unknowns; use `observe --tail` when you need newest raw text.

**Records.** When a check result, open question or handoff must outlive your turn, write it with `teerex records` in `~/.local/state/teerex-records` (once: `teerex records init --store ~/.local/state/teerex-records`). Put private text in a JSON `--fields-file -` rather than flags. **Before you stop on unfinished work, park:** `teerex records park --store … --host <host> --socket <socket> --session "$REX_SESSION" --block "$REX_BLOCK" --writer <your name> --fields-file -` with `question` and `next_action {actor, step, stop_when}`. Attach every teerex receipt that matters: `teerex records attach --id <id> --by <you> --evidence <packet.json> --check-command "<argv>" --assertion passed|failed|unknown --establishes "…" --does-not-establish "…"`. Never infer the assertion from exit 0. Record skipped checks with `records add omission` and leftovers with `records add cleanup`. In a decision card's `context`, add `records: teerex records resume --id <id>`. Run `records lint --id <id>` before reporting and name the id in your report. To pick work up, run `teerex records resume --id <id>` first; use `records navigate --focus yes` only if you need the pane.

**Decisions.** When you settle a decision that someone could later reasonably reopen, record it with `teerex records new --kind decision` in `~/.local/state/teerex-records`. Include the claims it rests on (`--depends-on` pins for each version, ref or issue state they assume), at least one rejected option with `revisit_when`, and an invalidator. Before acting on an older decision, run `records revalidate --id <id>`. If it says `needs_review`, report that instead of acting on it. Never reopen a rejected option whose condition has not changed; ask the seat if you think it should be.
