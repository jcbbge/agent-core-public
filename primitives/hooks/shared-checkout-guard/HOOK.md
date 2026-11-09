---
name: shared-checkout-guard
description: Refuses commands that discard uncommitted work or rewrite history in a working tree the agent does not exclusively own.
---

# Shared Checkout Guard

**Event:** before a shell command runs.

**Refuses** a command that throws away working-tree changes or rewrites history — a hard reset,
discarding all or some file changes, forced cleaning of untracked files, dropping or clearing
stashed work — when the target tree has uncommitted changes that are not all the agent's own.

**Allows** the same command on a clean tree, and on a tree whose changes are all the agent's own.

**Judges code, not text.** Only what the shell would execute counts. A commit message, a quoted
string, a heredoc body or a backticked mention of a dangerous command is never refused.

**When it cannot tell:** a dirty tree whose ownership cannot be determined is refused; a target
directory it cannot resolve is refused. Every other failure of the guard itself allows.

**The refusal says:** which command, which tree, why it would lose work, and to get the other work
to safety first.

**Off switch:** an explicit per-command override, recorded.

`scripts/shell-code-only.sh` is a sourced code-versus-text parser helper.
No blocking handler is shipped here.

Refusal enforcement follows the [worker exception](../../rules/worker-guards/RULE.md).
The exception does not authorize discarding another agent's work.
