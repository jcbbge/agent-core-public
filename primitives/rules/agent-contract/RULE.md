---
name: agent-contract
description: "How every agent starts, messages, waits on, reports to and reaps another agent, on Rex. Loaded by every agent."
---

# The agent contract

Binds every agent that starts, messages or reports to another (Josh, 2026-11-14 and 2026-11-20).
rexconfig's commands enforce most of it; it holds where they don't.

## Starting one

- Every piece of work is a task on Rivet, started from a Rex block; each agent is a disposable hand for
  one step. The task is the tab: a hand runs as a pane inside its task's tab, never in a tab of its own
  (Josh, 2026-11-24). `start-work [--run <name>] --brief-file <brief.md> <session> <name> --
  <claude|codex|pi>` prints the run and its pane id; the same `--run` resumes it.
  A harness's own sub-agent is allowed only inside the system (Josh, 2026-11-23): it picks up a task
  (`Task: <key>` in its brief), follows the contractor rulebook (`~/rivet/CONTRACTOR.md`), answers NQ on
  that task and talks to other agents only through Rex. Never work outside Rivet, Rex and NQ.
- Josh sees the task by itself: done or not, and if not, what is stuck and the one question. It is done
  only once the agent's final report has returned. Nobody relays it.
- The brief has the seven sections of the [brief template](../../tools/agent-messaging/BRIEF-TEMPLATE.md);
  `start-work` refuses one that lacks any. Provision in full: the receiver must never rediscover what
  you knew.
- Before handing work to anyone (another person, the oracle, a harness sub-agent or a task's sub-task),
  ask from the receiver's seat: (1) If I were given this task, would I have all the information needed
  to complete it? (2) Would I have questions about my next steps? (3) Is any detail ambiguous?
  Only **yes, none, none** passes. Write why for each answer. If one fails, improve the brief: look
  ahead for discrepancies, resolve every question and settle every reading before handing it off.
  The bar is that a reader cannot misread the instructions. Include this required section in the brief:

  ```markdown
  # Handoff check
  1. Everything needed: yes. <what the brief provides and where>
  2. Questions about next steps: none. <the next steps in order>
  3. Ambiguity: none. <each possible reading and how the brief settles it>
  ```

  Each answer's explanation belongs on that line. The gate checks the form, not whether the reasons
  are sound; the sender remains responsible for their substance. Rivet's internal step packets derive
  from checked work words, not fresh hand-offs.
- You are its starter. You answer every message it sends, check its proof yourself, and answer for it.
- Every run goes through the work (global directive), whoever opened the starter's pane. Its report
  reaches the starter whenever an agent runs in that pane; who opened the pane never decides.

## Receiving one: NQ first

1. Put each brief item in your list: `scratch todo "<item>"`, one each, none dropped or merged.
2. Confirm: `scratch confirm --understanding "<purpose, outcome, scope, evidence>" --unclear "None"
   --ambiguous "None" --ready yes`. If anything is unclear, say it and use `--ready no`.
3. Ready: start at once. Not ready: wait for `NQ ANSWER`. Each answer is one turn; a fourth question
   holds the work (the tools count). Every step keeps its own NQ exchange, three rounds at most; any
   issue or blocker is a question through NQ. NQ passes through Rex and only flags a warning; after three
   rounds the question goes to Josh by `agent-ask`.

Then you have three moves and no others: **complete** the task; **report** it complete; **report a
problem** (what is stuck, what you tried, what you need) and wait for the answer. Stay inside the brief.
Something outside it: tell your starter once (what, where, why now, what you did not touch) and drop it.

## The working list

One step at a time: `scratch now "<item>"`, then `scratch done --proof "<evidence>"`. Any doubt or
blocker: `scratch flag "<what is stuck; what you tried; what you need>"` at once (it is the task's
blocker), then keep doing what does not depend on it. A turn ends finished or flagged, never "I'll
check back": you have no clock. The list belongs to the task in Rivet; `scratch` reads and writes it there.

## Messages

- `agent-send <session> <pane> <your name> "<message>"`, or `agent-send starter <your name> "<message>"`,
  is the only way one agent talks to another. It stamps who you are and how to reply, types and submits in
  one act, and answers **served** (the receiver's own status turned to working) or **failed**, with why.
  **Queued** means saved, not delivered.
- Reply to the message's `reply-to:` line.
- The seat is an agent like any other: message it with `agent-send` when you have something for it.
  A decision only Josh can make still goes by `agent-ask`.
- Your report is your turn's last message; the turn hook delivers it to your starter, once. Never also
  send it with `agent-send`. The same report is the run's return.

## Questions

- About your work: your starter, by `agent-send`. Your starter settles what Josh's rubric can.
- A decision only Josh can make (the global *Ask first* list, or something he never gave): ask him
  yourself, in the background, with `agent-ask <your name> --title "<a few words>" --task "<original
  task>" --purpose "<what it is for>" --intent "<what you are trying to achieve>" --ask "<what he
  decides>" --option "A: <gains> / <loses>" --option "B: <gains> / <loses>" --recommend "A: <why>"`, each
  part a full sentence. It puts the question to him as a native Rex prompt, waits for his answer and prints his words
  verbatim (`text`), the option he chose if any (`answer`) and a receipt; act on his words. If it fails
  (it could not queue, or the decision was stopped), report that to your starter as a problem, with the
  question. The [rex skill](../../skills/rex/SKILL.md) has the details.
- Never stop on a menu or prompt in your own pane; nobody watches it.

## Waiting and seeing

- **On an agent:** end your turn. Its message wakes you.
- **On a process:** run it in a Rex pane and `rex wait <block> --for <duration>`, or `rex run --wait`.
  In a Lua script, `rex.wait(event, filter, timeout)` blocks until the event.
- **Another pane's state** is its Program Status record:
  `rex do com.superlogical.terminal.program_status -b <pane>`. Its harness and `agent-hook` write it;
  never write status for another pane yourself. The task-view controller, not the agent, writes the live state mark at the start of each tab's name.
- Never poll, and never read another agent's screen to wait or to learn its state.

## Panes

- Close, rename, move or type into only panes you spawned, by the id `start-work` printed. Leave every
  other pane alone, even one that looks dead; name it to your starter. An agent message is the exception.
- Only Josh alters or closes the seat or its tab; `agent-close` refuses it.
- Never pause an agent (no SIGSTOP or SIGTSTP). To stop its work, tell it; to end it, close its pane.
  Text typed into an input is always submitted.

## Reporting

A report goes once, to your starter, and stops there; nobody forwards it. Only a verified final report
or a blocker you could not clear goes. A report
says, in plain words: the result and where it is; the proof (what you ran this session, what it
showed); what is unproven and why; the decisions you made by the rubric; and everything you started,
each shown gone or named as still running with who stops it.

## Reaping

Nothing an agent opens outlives it (Josh, 2026-11-24). A tab is a task: it shows a task's state in Rex's
own vocabulary (working, blocked, done, error) and leaves when the task is done.

- **You own what you open.** Every pane, tab, window and session you create goes on your ledger by
  itself (rexconfig's `rex`, `start-work` and `task-view`). Your final report is refused while anything
  on it is open, then the turn hook reaps it; your close and `agent-close` reap it too, deepest first.
  `rex-reap` reaps your own now; `rex-reap --keep <id> --to <who>` hands one that must outlive you to a
  named owner, and your report names it.
- **A closed pane ends its task.** It never stays blocked waiting on a pane that is gone.
- Prefer commands that run once and exit. Anything long-running runs in a Rex pane you own, never
  detached; stop its whole process group.
- A finished worker closes its own pane once its report is served. One still open after you accept its
  report: `agent-close --accept <session> <pane>`.
- Remove what you made for the work (worktrees, branches, servers, containers, temp dirs) on hive and
  the M5, and only that. Someone else's leftovers, however dead: name them to your starter.
