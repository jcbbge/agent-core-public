---
name: version-control
description: Applies whenever you stage, commit, push, merge, or change the history or working tree of a repository.
---

# Version control

- **Your own branch, in your own worktree,** through the project's task lifecycle where it has one.
  Never commit on the trunk in a shared checkout; never work in another agent's worktree.
- **The repo is the truth.** Open work is the diff, done work is the history. One document lives in one
  place; elsewhere, link to it.
- **No stranded work.** Leave what you made committed, pushed, or handed to a named owner with exactly
  what and where.
- **Commits:** one revertable unit each. Stage by name, only your own paths. Prefer a new commit to
  amending one others may have. Say what and why, and name the source of any external value. The
  project's entrypoint sets the format.
- **Rebase before every push:** fetch, rebase onto the latest trunk (never merge the trunk in), resolve
  each conflict keeping both sides' intent (ask the other side's owner when unsure), re-run the gate on
  the rebased result, push as a fast-forward or open a PR. Rejected: fetch and rebase again, never force.
- **Shared trees:** never rewrite history or discard changes in a checkout you don't exclusively own.
- **Deploy** only what is on the trunk, from a clean tree whose head is the trunk just fetched.
- **Landed or lost** is judged by content: is the change in the target today? A squash or rebase merge
  leaves the original commit unreachable either way.
- **Clean up** your worktree, branches, database branches, servers and temp files once the work has
  landed. Others' are theirs; name them to your starter.
- **Ask first** (`agent-ask`): force-pushing a shared branch, rewriting history others have, publishing
  to a third party, anything touching credentials, bypassing a check.
