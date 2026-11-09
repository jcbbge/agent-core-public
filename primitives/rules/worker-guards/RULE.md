---
name: worker-guards
description: Applies to every refusal-capable guard, when installing it or when running agents as workers.
---

# Worker guards

A worker is an agent launched by a durable execution engine that keeps the worker's steps and
enforcement on its own work item. The exact value `MW_WORKER=1` marks a worker. Workers pass every
refusal-capable guard. Other values, including unset, empty, `0` and `true`, retain normal
enforcement.

Check the worker identity before reading guard input, probing dependencies, loading
helpers, parsing configuration or accessing guard state. Passage is silent: no output,
denial or guard-state changes.

For a tool with both guarding and ordinary commands, apply the exception only to
its guarding command, before initialization. Nonblocking observers and ordinary
tool commands retain their behavior. Non-worker behavior and explicit overrides
remain unchanged.

This exception skips mechanical enforcement; it does not authorize committing
secrets, pushing known scanner hits, destructive operations, unattended installation
without the operator's consent, or invisible agents. Grounding and visible-work
duties still apply. A worker's work item is not replacement security enforcement.
