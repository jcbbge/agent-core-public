---
name: trufflehog
description: Secret scanner for git history and directories. Use for an audit sweep or a second opinion beside gitleaks, never in place of it.
---

# trufflehog — secret sweep

Binary: `trufflehog` on PATH. Source: https://github.com/trufflesecurity/trufflehog.
Install: `brew install trufflehog`. Present when `trufflehog --version` answers.

[gitleaks](../gitleaks/TOOL.md) satisfies the [secrets rule](../../rules/secrets/RULE.md)'s scanner
requirement; trufflehog complements it and never replaces it.

## When

- Audit sweep of a repository's whole git history for leaked credentials.
- Sweep of a local directory, including files git does not track.
- A second opinion beside gitleaks.

Other sources exist; read `trufflehog --help` before using one.

## When not

- Commit-time scanning → gitleaks under the secrets rule, with the
  [credential-guard](../../hooks/credential-guard/HOOK.md) hook.
- A known exact string → `rg`.

## How

```bash
trufflehog git file://<repo> --no-verification --no-update --fail --json \
  | jq -c '{detector: .DetectorName, file: .SourceMetadata.Data.Git.file, line: .SourceMetadata.Data.Git.line}'
trufflehog filesystem <path> --no-verification --no-update --fail --json \
  | jq -c '{detector: .DetectorName, file: .SourceMetadata.Data.Filesystem.file, line: .SourceMetadata.Data.Filesystem.line}'
```

- Every run passes `--no-update`, so the binary never updates itself mid-task.
- Findings carry the secret values. Keep them out of context: always project the `--json` stream
  to detector, file and line before reading it. Cite those, never the value, in any report, log
  or commit.
- A zero exit is not a clean scan. `--fail` exits 183 when anything is found, but behind the `jq`
  pipe the status is `jq`'s unless the shell sets `pipefail`. Count the projected lines.

## Verification needs a yes

Without `--no-verification`, trufflehog sends each credential it finds to that credential's
provider to test it. That is an outward action and needs the operator's yes first. `--results`
and `--only-verified` filter on verification status, which exists only after live verification,
so either one is live verification too.
