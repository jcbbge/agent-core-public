---
name: worker-guards
description: Applies to every refusal-capable guard, when installing it or when running agents as workers.
---

# Worker guards

A worker is an agent launched by a durable execution engine that enforces its own steps on its work
item. Exactly `MW_WORKER=1` marks one; any other value, unset included, keeps normal enforcement.

- Every refusal-capable guard lets a worker pass, silently: it checks `MW_WORKER` before reading input,
  probing dependencies, loading helpers, parsing config or touching guard state, and changes nothing.
- A tool that both guards and does ordinary work skips only its guarding command. Observers and
  ordinary commands behave as always.
- The exception skips enforcement, not the rules: no secrets committed, no scanner hits pushed, nothing
  destructive, nothing installed without Josh's yes, no invisible agents.
