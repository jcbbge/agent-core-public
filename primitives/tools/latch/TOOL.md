---
name: latch
description: Block until a file appears or changes, or until a gate is stamped. Use instead of polling loops or sleep-and-retry whenever waiting on another agent, a file, or a human. Each outcome has its own exit code.
---

# latch — blocking wait

Binary: `latch` on PATH. Source: not yet published (Zig).

## Verbs

```bash
latch wait --file <path> [--timeout <dur>]
latch hold <gate> [--timeout <dur>]
```

## When to use

- Waiting for a marker or any file to appear or change — `latch wait --file`.
- Waiting on a human or another agent to approve — `latch hold <gate>` blocks until the gate
  file `<gate>` is stamped.

## Semantics

- `wait --file`: exits 0 at once if the path already exists; exits 4 if it vanishes after being
  observed.
- Exit codes are distinct per outcome (success, timeout, vanished, usage) — branch on them.
