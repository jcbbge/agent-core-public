---
name: ending-session
description: Preserve shared understanding and continuity when pausing, ending or handing over a session. Establish what changed, what remains and what must carry forward.
---

# Ending Session

Ending preserves the thread; it does not require all work to be finished. We should
leave connected about what changed, what is still open and how to resume without the
operator having to reconstruct the session. These are conditions for continuity,
not a shutdown routine or a new body of work.

## We share what actually happened

The result is understood against the original intent: what moved, what did not,
what changed our understanding, and what the available evidence supports. Distinguish
work that exists from work that is verified, integrated or live when that matters.
Do not turn confidence, a report or a process exit into independent acceptance.

Gaps, uncertainty and unfinished work can remain honestly named. Pausing is not
failure, and sign-off is not authority to manufacture completion or launch extra checks.

## The work remains intact and resumable

The actual work and its location are clear, including existing or concurrent work
that is not ours to change. No commit, push, new branch, worktree or document move is
required merely because a conversation is ending; teardown follows landing, not the
clock. Actual task and project requirements still apply; report their state without
inventing an additional gate.

If durable work continues, we know what remains active, why, and who owns the next
move. Ending the conversation is not the same as stopping that work. Anything this
session leaves behind is accounted for, not swept away to make the close look tidy.

## What we started is stopped

A piece of work runs through its project's task lifecycle: its own branch and worktree,
its own database cloned from production, its own server, provisioned together when the
work starts. When the work has landed in the trunk, the session that landed it reaps all
of it through that lifecycle: server and containers stopped, database deleted, worktree
removed, branch deleted locally and on the remote. Landed and not reaped is not done.

Work that has not landed keeps what it holds, and the handoff names each resource, where
it is and who owns it. Anything else this session started (a process, a watcher, a
container, a background run) is stopped, or named with why it stays and how to stop it.
What other sessions started is theirs to stop.

Teardown leaks two ways even when it is attempted. Removing a worktree directly leaves
its server and containers running against a database that no longer exists; tear down
through the lifecycle, which stops them first. A detached server that keeps the caller's
output open hangs whatever is capturing it; detach it from the caller's output entirely.

## Continuity reaches the next session

Circadian memory is part of every close. Consider what a future session could not
re-derive: the reason for a decision, an operator correction, a changed assumption,
a consequential discovery or an unresolved question. Carry material new understanding
through Circadian's supported memory path; distinguish a submitted proposal from
accepted memory. Do not manufacture an entry when nothing durable changed.

When Graphiti is available, preserve relevant changes to project facts and relationships
with their context and temporal meaning. Do not copy every fact into both memory systems.
Neither memory system is a transcript dump or a duplicate of repository or delivery state.

The handoff carries the thread: the purpose being pursued, the meaningful change,
what remains open, where the evidence lives, and the next useful move or question and
why it follows. Use the existing records rather than creating a second work catalog.

## Shared closure stays light

Give a brief, natural acknowledgement of where we are. Make an important unresolved
point visible, but do not recite a fixed status block, score the session, or impose a
retrospective questionnaire. The operator and the next session need continuity,
not proof that a closing ritual was performed.
