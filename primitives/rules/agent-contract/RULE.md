---
name: agent-contract
description: "How every agent starts, messages, waits on, reports to and reaps another agent, on Rex. Loaded by every agent."
---

# The agent contract

Binds every agent that starts, messages or reports to another (Josh, 2026-11-14 and 2026-11-20).
rexconfig's commands enforce most of it; it holds where they don't.

## Starting one

- Every agent is a visible Rex pane: `agent-spawn --brief-file <brief.md> <session> <name> -- <claude|codex|pi>`.
  It prints the pane id. Never a harness-internal sub-agent (Claude's Agent/Task tool, Codex's) or a
  background process outside Rex.
- The brief has the six sections of the [brief template](../../tools/agent-messaging/BRIEF-TEMPLATE.md);
  `agent-spawn` refuses one that lacks any. Provision in full: the receiver must never rediscover what
  you knew.
- You are its starter. You answer every message it sends, check its proof yourself, and answer for it.

## Receiving one: NQ first

1. Put each brief item in your list: `scratch todo "<item>"`, one each, none dropped or merged.
2. Confirm: `scratch confirm --understanding "<purpose, outcome, scope, evidence>" --unclear "None"
   --ambiguous "None" --ready yes`. If anything is unclear, say it and use `--ready no`.
3. Ready: start at once. Not ready: wait for `NQ ANSWER`. Each answer is one turn; a fourth question
   holds the work and alerts the seat (the tools count).

Then you have three moves and no others: **complete** the task; **report** it complete; **report a
problem** (what is stuck, what you tried, what you need) and wait for the answer. Stay inside the brief.
Something outside it: tell your starter once (what, where, why now, what you did not touch) and drop it.

## The working list

One step at a time: `scratch now "<item>"`, then `scratch done --proof "<evidence>"`. Any doubt or
blocker: `scratch flag "<what is stuck; what you tried; what you need>"` at once, then keep doing what
does not depend on it. A turn ends finished or flagged, never "I'll check back": you have no clock.

## Messages

- `agent-send <session> <pane> <your name> "<message>"`, or `agent-send starter|seat <your name> "<message>"`,
  is the only way one agent talks to another. It stamps who you are and how to reply, types and submits in
  one act, and answers **served** (the receiver's own status turned to working) or **failed**, with why.
  **Queued** means saved, not delivered.
- Reply to the message's `reply-to:` line.
- While a pane labelled `desk` exists, anything addressed to the seat goes to the desk (`agent-send` does
  this). Never type into the seat's pane.
- Your report is your turn's last message; the turn hook delivers it to your starter, once. Never also
  send it with `agent-send`.

## Questions

- About your work: your starter, by `agent-send`. Your starter settles what Josh's rubric can.
- A decision only Josh can make (the global *Ask first* list, or something he never gave): ask him
  yourself, in the background, with `agent-ask <your name> --title "<a few words>" --task "<original
  task>" --purpose "<what it is for>" --intent "<what you are trying to achieve>" --ask "<what he
  decides>" --option "A: <gains> / <loses>" --option "B: <gains> / <loses>" --recommend "A: <why>"`, each
  part a full sentence. It opens the decision card, waits for his answer and prints his words verbatim
  (`text`), the option he chose if any (`answer`) and a receipt; act on his words. If it fails (the card
  could not open, or he closed it without answering), report that to your starter as a problem, with
  the question. The [rex skill](../../skills/rex/SKILL.md) has the details.
- Never stop on a menu or prompt in your own pane; nobody watches it.

## Waiting and seeing

- **On an agent:** end your turn. Its message wakes you.
- **On a process:** run it in a Rex pane and `rex wait <block> --for <duration>`, or `rex run --wait`.
  In a Lua script, `rex.wait(event, filter, timeout)` blocks until the event.
- **Another pane's state** is its Program Status record:
  `rex do com.superlogical.terminal.program_status -b <pane>`. Its harness and `agent-hook` write it;
  never write status for a pane yourself, or relabel a tab to show state.
- Never poll, and never read another agent's screen to wait or to learn its state.

## Panes

- Close, rename, move or type into only panes you spawned, by the id `agent-spawn` printed. Leave every
  other pane alone, even one that looks dead; name it to your starter. An agent message is the exception.
- Only Josh alters or closes the seat or its tab; `agent-close` refuses it.
- Never pause an agent (no SIGSTOP or SIGTSTP). To stop its work, tell it; to end it, close its pane.
  Text typed into an input is always submitted.

## Reporting up

Workers report to their lead, leads to their coordinator, coordinators and role holders to the desk
(else the seat). Upward goes only a verified final report or a blocker you could not clear. A report
says, in plain words: the result and where it is; the proof (what you ran this session, what it
showed); what is unproven and why; the decisions you made by the rubric; and everything you started,
each shown gone or named as still running with who stops it.

## Reaping

- Prefer commands that run once and exit. Anything long-running runs in a Rex pane you own, never
  detached; stop its whole process group.
- A finished worker closes its own pane once its report is served. One still open after you accept its
  report: `agent-close --accept <session> <pane>`.
- Remove what you made for the work (worktrees, branches, servers, containers, temp dirs) on hive and
  the M5, and only that. Someone else's leftovers, however dead: name them to your starter.
