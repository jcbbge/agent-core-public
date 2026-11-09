---
name: pickbrain
description: Semantic search over past agent session transcripts (any harness that writes JSONL transcripts), not source code. Use for "what did we decide", "that conversation where we fixed auth", recall across sessions. Never use this to find a function in a repo.
---

# pickbrain — session recall

Binary: `pickbrain` on PATH. Source: https://github.com/dropbox/witchcraft (its `pickbrain` app). Indexes session JSONL locally.

## When

- Recall across previous sessions: decisions, failed approaches, where a fix landed.
- "Did we already try X?"

## When not

- Searching source → `colgrep` / `coraline` / `rg`.

## How

```bash
pickbrain auth middleware fix
```

There is no `--help`. Unknown flags are treated as query text. Do not go through a search router.
