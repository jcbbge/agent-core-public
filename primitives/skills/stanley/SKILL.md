---
name: stanley
description: Get a fast, bounded second look at a git diff — task fit, correctness, test gaps, security, performance, compatibility, failure or review-comment triage — without spawning another agent.
---

# Stanley

Stanley is a read-only checker for git diffs. It reads the diff, splits it
into hunks, asks a decision-only model fixed-choice questions about each, and
applies thresholds in code. It never edits, never runs tests, and on this
machine can never start another agent. Every result is advisory: an empty
findings list is not an approval, and every report lists what was not checked.

Reach for it when you are about to trust your own judgment about a diff:
before reporting a change done, before landing a worker's branch, when a test
log is long, when review comments pile up, when you need to find where
something lives in an unfamiliar repo.

## Requests (natural language; the request is the task)

```sh
stanley "Check whether these changes <the task as the requester wrote it>"
stanley "Review these changes for correctness bugs"
stanley "What important tests are missing from this diff?"
stanley "Summarize what changed"
stanley "Audit these changes for security vulnerabilities"
stanley "Look for performance regressions in this diff"
stanley "Could these changes break existing API consumers?"
stanley "Find the code involved when <symptom>"
npm test 2>&1 | stanley "Triage these failures"
gh api repos/O/R/pulls/N/comments | stanley "Triage these review comments"
```

Scope flags, the only ones that exist: `--scope worktree|staged|branch`,
`--base <ref>`, `--repo <dir>`, `--input <file|->`, `--json`, `--no-persist`.

## How to read a result

- `output.data.findings`: places to look, each with file and line range.
- `output.data.parked`: concerns below threshold. Skim them.
- `output.data.notChecked`: what it did not do. Read this every time.
- A `check` finding of `weak_task_relation` means a hunk does not look like
  it belongs to the task. Either it is scope creep, or the task text was too
  narrow. Decide which; do not ignore it.

## Rules

- Stanley is your tool. It is not a runtime, not a peer, not a delegate. It
  is wired so that it cannot spawn any agent; do not try to enable that.
- Run it inside the repository (or pass `--repo`). Files must be inside it.
- Its judgments are probabilities over small pieces of evidence. Cheap and
  fast (seconds, fractions of a cent). Run it often; verify what it flags.
- Do not put Stanley output in a report as if it were a test result. It read
  code; it did not run anything.
