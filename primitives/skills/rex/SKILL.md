---
name: rex
description: Rex is the terminal control plane - its server and everything that drives it on hive, its app on the M5 - sessions, tabs, panes, running and reading terminals, waiting on events, actions, native questions to Josh - plus teerex, the Rex extensions CLI, and rexconfig's agent commands. Use for any Rex task, any time an agent starts, waits on or talks to another pane, lays out work across machines, or before a Rex restart.
---

# Rex

Rex is the constant: build on it. Read the installed guide first, `rex __internal skill`, then
`rex --help`, `rex actions --json` and `rex api list` for what this server offers. Hive's server is
Preview; check a feature on it (`rex do -e 'return tostring(rex.ui ~= nil)'`) rather than assuming.
How agents start, talk, wait and report is the [agent contract](../../rules/agent-contract/RULE.md).

## The primitives

| Need | Use |
|---|---|
| Run something in a pane, wait for it | `rex run -s "$REX_SESSION" --label <name> --keep-open --wait -- <cmd>`; or `rex wait <block> --for <dur>` |
| Wait for any event in a script | `rex.wait(event, filter, timeout)` in a Lua script run by `rex do <script.lua>`; `rex events -s <session> --json` to see event names |
| A pane's state | its Program Status record: `rex do com.superlogical.terminal.program_status -b <block>`; its process: `rex block call -b <block> process` |
| A decision from Josh | `agent-ask`, which opens the decision card (below); his answer, in his own words, returns to the caller |
| A document for Josh | `rex do open_document path=<file.md>` from the seat's pane: leaf, floating over its window |
| A key, action, view or watcher | read [references/ecosystem.md](references/ecosystem.md) first; never a key the app or macOS already uses; rexconfig is the only writer of Rex's config. A view in a pane is an applet: the [rex-applet skill](../rex-applet/SKILL.md) |

## Asking Josh: the decision card

A decision only Josh can make goes by `agent-ask`, nothing else: no question on a tab, no inbox page, no
prompt in your own pane.

```
agent-ask <your name> --title "<a few words>" --task "<original task>" --purpose "<what it is for>" \
  --intent "<what you are trying to achieve>" --ask "<what he decides>" \
  --option "A: <what it gains> / <what it loses>" --option "B: <gains> / <loses>" --recommend "A: <why>"
```

- All six parts are required, each a full sentence (gains and losses too); `agent-ask` refuses otherwise.
- It opens a large floating Rex pane over the asker's session's active tab: Task, Purpose, Intent, The ask,
  each option's gain and loss, and the recommendation, wrapped and scrollable, never cut. Rex's palette
  only says a decision is waiting.
- He answers in a box at the bottom, typed or dictated. An option key only starts the answer; his words
  govern. Enter twice sends.
- Run it in the background. It blocks until he answers, then prints `{"answer", "text", "receipt"}`:
  `answer` is the option id, or `text` when he answered only in words; `text` is his words verbatim; the
  receipt is the record of his answer. Act on `text`.
- Exit 75: the card could not open. Exit 1: he closed it without answering (the decision is still owed),
  or the ask failed; stderr says which. Either way, report it to your starter as a problem, with the
  question. There is no fallback.

## teerex and rexconfig

- teerex (`teerex --help`) extends Rex: panes it opens, moves and closes, sends into a pane, the board,
  restart snapshot and restore, named hosts (`~/.config/teerex/hosts.json`, one host: `hive`). A missing
  verb is a jcbbge/teerex issue; never hand-build plumbing beside it.
- rexconfig (`~/rexconfig`, its README, `./install --check`) owns Rex's config and the agent commands:
  `agent-spawn`, `agent-send`, `agent-ask`, `agent-close`, `agent-role`, `scratch`, the `agent-hook`.
  `rex claude|codex|pi` starts that agent clean; any other `rex ...` is Rex itself.
- Machine check: `teerex doctor --all --config ~/.config/teerex/hosts.json`.

## Never

- Read another agent's screen to wait on it or learn its state, or poll: use the record, `rex wait`, or
  its message.
- Send input into your own pane, or any pane you did not spawn (an `agent-send` message is the exception).
- Run a Rex or teerex command on the M5; it runs only the Rex app.
- Restart Rex or kill its processes without Josh's yes. A restart of `rex.service` ends every agent
  inside it; take a restart snapshot first and record what cannot resume.
- Rename a shared session.
