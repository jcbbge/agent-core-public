---
name: ending-session
description: What an agent does at the end of a sitting ("end session"), or when it pauses or hands over. Unfinished tasks stay on Rivet; the sitting closes.
---

# Ending Session

Ending a sitting does not require the work to be finished. Unfinished tasks are normal; they live on
Rivet and carry into the next sitting.

## The close (not live yet)

"End session" is a Rex action. It ends the Rivet session actor (its unfinished tasks stay on Rivet) and
closes the Rex session. No agent closes tabs or the session by hand. Until the action is live, Josh closes
it himself.

## What you do at the end

- **Leave your task true.** Its state on Rivet says what moved, what didn't, and if not done, what is
  stuck and the one question. Say what exists apart from what is verified or live; never turn a report or
  an exit code into acceptance.
- **Finish your turn cleanly.** A turn ends finished or flagged. Reaping what you started follows the
  [agent contract](../../rules/agent-contract/RULE.md); a sitting's end adds nothing to it.
- **Carry what can't be re-derived.** Circadian memory is part of every close: a decision's reason, a
  correction from Josh, a changed assumption, an open question. Nothing else: not a transcript, not the
  task's state (Rivet holds that). Write nothing when nothing durable changed. Workers never write memory.

Keep it light: a brief acknowledgement of where things stand, and any unresolved point that matters.
No status block, score or retrospective.
