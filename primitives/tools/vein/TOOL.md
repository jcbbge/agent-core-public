---
name: vein
description: Mine agent session transcripts (JSONL) for what agents actually did — which commands they ran, how often they failed or retried, whether a hook fired. Use to back any claim about agent behavior with numbers instead of impressions.
---

# vein — transcript-corpus miner

Binary: `vein` on PATH. Source: not yet published (Zig).

## CLI

```bash
vein scan --sessions <path> [--out <commands.csv>]
vein scan --last N [--out <commands.csv>]
vein report --sessions <path> [--out-dir <dir>]
vein report --last N [--out-dir <dir>]
vein report --csv <commands.csv> [--out-dir <dir>]
```

- `--sessions <path>`: text file, one session id / absolute transcript path / cwd-relative `.jsonl` per line (`#` comments and blanks ignored).
- `--last N`: newest N transcripts across every transcript directory it is pointed at, by mtime.
- `report` emits four files: `verbs.md`, `retries.md`, `hooks.md`, `failures.md`.

## Truth law

- Schema drift or unknown JSONL shape → literal `UNKNOWN`, exit 4 — never invented aggregates.
- Unresolvable session token → `UNKNOWN: unresolvable session <token>` on stderr, exit 3.
- Exit codes: 0 ok · 2 usage · 3 I/O · 4 schema-UNKNOWN. Distinct, never collapsed.

## Oracle

