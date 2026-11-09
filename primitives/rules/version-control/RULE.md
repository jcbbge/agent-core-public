---
name: version-control
description: Applies whenever you stage, commit, push, merge, or change the history or working tree of a repository.
---

# Version Control

## No stranded work

Work that exists only in a working tree is one bad command from gone. Every session that produces
work leaves it preserved the way the assignment allows — committed, pushed, or handed to the named
owner with a report of exactly what and where. Unfinished is not a reason to discard.

## Commits

- One coherent unit per commit: revertable on its own. Two things that would be reverted
  separately are two commits.
- Stage by name, only your own paths. Never stage everything wholesale, and never commit another
  agent's changes because they happen to be in the index.
- Prefer a new commit over amending one that others may have.
- Before staging config, look for secrets in it. A secret found is removed, never bypassed.

## One agent, one branch, one worktree

Start every piece of work on a new branch in a new worktree, through the project's own task
lifecycle where it has one. Never commit on the trunk in a shared checkout, and never work in
a worktree another agent holds.

## Rebase before every push

Several agents land on the same trunk. A branch that has not caught up overwrites what landed
while it was away, in history when a merge resolves a conflict by taking one side, and in
production when it is deployed.

1. `fetch`, then rebase your branch onto the latest trunk. Never merge the trunk into it.
2. Resolve each conflict by keeping both sides' intent. Taking one side wholesale is how work
   is lost; when you cannot tell what the other side meant, ask its owner.
3. Re-run the project's gate on the rebased result. A gate run before the rebase proves nothing
   about what you push.
4. Push as a fast-forward, or open a pull request where the project uses them. If the push is
   rejected, someone landed first: go back to step 1. Never force-push the trunk or any
   branch someone else has.
5. Deploy only what is on the trunk, from a clean tree whose head is the trunk as just fetched.

## Clean up what you provisioned

When your work has landed, remove everything you created for it: the worktree, the local and
remote branch, database branches or clones, servers, containers and temporary files. Remove
only what you provisioned. Someone else's worktree, branch or database is theirs even when it
looks abandoned; name it to the operator and leave it.

## Shared trees

Never run a command that rewrites history or discards working-tree changes in a checkout you do not
exclusively own. If a tree is dirty and not all yours, get the other work to safety first, or do not
run it.

## Landed or lost

Judge whether work landed by its content, not by whether a commit is reachable. A squash or rebase
merge makes a new commit, so the original is unreachable whether the work landed or vanished. Ask
first: is the change present in the target today, or was it present and later changed? Only when
the content is absent does reachability answer the next question — mergeable, or truly lost.

## Ask first

Force-pushing a shared branch, rewriting history others have, publishing to a third party,
anything touching credentials, bypassing a check, and anything destructive or irreversible.
