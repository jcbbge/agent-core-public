---
name: rex
description: Rex is the terminal control plane - its server and everything that drives it on hive, its app on the M5 - sessions, tabs, panes, running and reading terminals, waiting on events, actions, native questions to Josh - plus rexconfig's agent commands and agent messaging through the work engine's Rex bridge. Use for any Rex task, any time an agent starts, waits on or talks to another pane, lays out work across machines, or before a Rex restart.
---

# Rex

Rex is the constant: build on it. Read the installed guide first, `rex __internal skill`, then
`rex --help`, `rex actions --json` and `rex api list` for what this server offers. Hive's server is
Preview; check a feature on it (`rex do -e 'return tostring(rex.ui ~= nil)'`) rather than assuming.
How agents start, talk, wait and report is the [agent contract](../../rules/agent-contract/RULE.md).
What a server, block and client are, why actions live in the client's config, how servers reach each
other, and the unpublished block plugins: [references/model.md](references/model.md).
Rex is the room: it shows the work and carries messages, and holds nothing durable. What must last
(sessions, tasks, to-dos, agent runs) lives on Rivet.

## The primitives

| Need | Use |
|---|---|
| Run something in a pane, wait for it | `rex run -s "$REX_SESSION" --label <name> --keep-open --wait -- <cmd>`; or `rex wait <block> --for <dur>` |
| Wait for any event in a script | `rex.wait(event, filter, timeout)` in a Lua script run by `rex do <script.lua>`; `rex events -s <session> --json` to see event names |
| A pane's state | its Program Status record: `rex do com.superlogical.terminal.program_status -b <block>`; its process: `rex block call -b <block> process` |
| A decision from Josh | `agent-ask`, which puts the question to him as Rex's own prompt (below); his answer, in his own words, returns to the caller |
| A document for Josh | `rex do open_document path=<file.md>` from the seat's pane: leaf, floating over its window |
| A key, action, view or watcher | read [references/ecosystem.md](references/ecosystem.md) first; never a key the app or macOS already uses; rexconfig is the only writer of Rex's config. A view in a pane is an applet: the [rex-applet skill](../rex-applet/SKILL.md) |

## Asking Josh: Decisions

A decision only Josh can make goes by `agent-ask`, nothing else: no question on a tab, no inbox page, no
prompt in your own pane. A task that exhausts its three NQ rounds asks the same way.

```
agent-ask <your name> --title "<a few words>" --task "<original task>" --purpose "<what it is for>" \
  --intent "<what you are trying to achieve>" --ask "<what he decides>" \
  --option "A: <what it gains> / <what it loses>" --option "B: <gains> / <loses>" --recommend "A: <why>"
```

- All six parts are required, each a full sentence; `agent-ask` refuses otherwise. Write the ask as one
  short question to "you".
- It reaches him as Rex's own prompt on his Mac (rexconfig's `decision` action calls `rex.ui.pick`): the
  question as its title, one row per option (what it gains, then what it costs), a star on the
  recommendation. He picks a row or types his own words. No tab opens and nothing takes focus.
- Run it in the background; it waits as long as he takes. It returns `{"answer","text","receipt"}`:
  `answer` is the option id, or `text` when he answered only in words; `text` is his words verbatim.
  Act on `text`.
- Exit 75: the question could not reach a Rex app. Exit 1: he closed it without answering (declined),
  or the answer could not be recorded. Either way, report it to your starter as a problem, with the
  question.

## Messages and rexconfig

- `agent-send` delivers through the work engine's Rex bridge, which holds the one Rex connection. A
  message is served only when the receiver's own status turns to working after it; otherwise it is
  queued, held (the receiver is held, as in Focus Mode) or failed with a reason. The bridge drains
  queues itself. teerex is retired (2026-11-23).
- Rex handles pane lookup, layout, capture, events and session persistence. Use
  `rex block capture` for command output from a pane you started.
- rexconfig (`~/rexconfig`, its README, `./install --check`) owns Rex's config and the agent commands:
  `start-work`, `agent-send`, `agent-ask`, `agent-close`, `agent-role`, `scratch`, the `agent-hook`, and
  the task views (one tab per open task). `rex claude|codex|pi` starts that agent clean; any other `rex ...` is Rex itself.
- On hive, `~/rexconfig/install --check` checks configuration.
  `rex-check api` checks the live Rex API.

## Never

- Read another agent's screen to wait on it or learn its state, or poll: use the record, `rex wait`, or
  its message.
- Send input into your own pane, or any pane you did not spawn (an `agent-send` message is the exception).
- Run a Rex command on the M5; it runs only the Rex app.
- Restart Rex or kill its processes without Josh's yes. A restart of `rex.service` ends every agent
  inside it. Save unsent input first and record which agents need to resume.
- Rename a shared session.
