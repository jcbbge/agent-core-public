---
name: rivet-oracle-toolkit
description: Peer into any part of Made Well on Rivet - a run, a step, an agent assignment and its tool calls, an engine actor, a node, a container, the engine itself - from the captured record and the vendor's APIs, read-only, with mw inspect. Use when holding the rivet-oracle role, when a Made Well run is stuck, held, failed or slow, when an actor is Pending or Crashed, when asked "what happened to run X", "why is this held", "is the engine healthy", or to diagnose a provoked failure. Not for the deprecated old install (~/rivet, rv): its history is read-only in rivet_history and the snapshot.
---

# rivet-oracle-toolkit — see everything, change nothing

Made Well (Josh's application, `~/madewell`) runs on Rivet (the vendor: engine, actors, workflows, Pi, agentOS).
Every fact of its work is written, as it happens, into its own Postgres (`127.0.0.1:7432`, schema `mw`; contract
`~/madewell/db/RECORD.md`). The engine runs in compose project `madewell` (`127.0.0.1:7420`). One id finds
everything: `run_id`, `step_id`, `assignment_id`, `tool_call_id`, `actor_id`, `trace_id`.

## The front door: `mw inspect` (read-only, every command takes `--json`)

| Question | Command |
|---|---|
| Is everything up? capture queue/spool? | `mw inspect health` |
| What happened in this run, in order? | `mw inspect run <run_id>` (timeline, steps, attempts, evidence, holds, acceptance, assignments, tool calls, errors, spans) |
| One step / one agent assignment / one tool call | `mw inspect step <run> <step>` · `assignment <id>` · `tool <tool_call_id>` (`--payloads` shows redacted bodies) |
| Why is this actor Pending / Crashed? | `mw inspect actor <actor_id or name/key>` (its `why` lines follow the vendor's statuses) |
| Engine: pools, nodes, namespaces, actor counts | `mw inspect engine` (its `diagnosis` names any pool with no connected node) |
| A process or container: state, restarts, logs | `mw inspect service node|engine|services|services-app|db` |
| Logs from node, engine and agentOS workers, one query | `mw inspect logs --source S --level L --run R --since T --grep X` |
| Errors of every origin | `mw inspect errors --since T` |
| Traces | `mw inspect spans <trace_id>` or `--run R` (tree) |
| Metrics | `mw inspect metrics <name> --since T` |
| Anything mentioning an id or a word | `mw inspect search <text|id> --since T` |
| The old install's 652 agent calls | `mw inspect history [run]` |

Another engine (a throwaway for drills): set `MADEWELL_ENV_FILE` to an env file with `MADEWELL_ENGINE_ENDPOINT`,
`MADEWELL_ENGINE_NAMESPACE`, `MADEWELL_ENGINE_ADMIN_TOKEN` (and the `MADEWELL_PG_*` passwords for the record).
Raw SQL when a view is missing: role `madewell_ro` (password in `~/madewell/.env`, read it in code, never argv).

Nothing here changes state. Restarting the node or engine, sleeping or destroying an actor is outside this
skill: the rivet-oracle role's restart rule applies (save every run's `mw inspect run --json` and
`mw inspect engine --json` first, compare after), and anything destructive asks Josh first.

## The vendor's statuses, and what each looks like here

The actor list API on engine 3.1.1 leaves every status timestamp null, so read status from the evidence:

| Status (rivet.dev/docs/statuses) | Evidence | Command |
|---|---|---|
| Starting / Running / Sleeping | `engine.actor` events from the node's lifecycle hooks | `mw inspect actor` → `status` |
| **Pending**: waiting for a node | the actor exists; its pool has no connected node | `mw inspect engine` → `diagnosis`; `actor` → `why` |
| **Crashed**: failed to start or fatal error | node log `actor start failed … generation N` repeating; caller gets `actor_stopped_while_waiting` | `mw inspect logs --source node --level error`, `actor` |
| Destroyed | `destroy_ts` set | `mw inspect actor` |

## Five failures provoked on a throwaway (evidence: `~/madewell/proof/5/drills/`)

1. **No node in the pool** → the call hangs until the caller's timeout, no error; `/pools/<p>/nodes` empty.
   Fix: start the node; check `RIVET_ENDPOINT`, namespace.
2. **Node in the wrong pool** (`node.poolName` missing or wrong: the old key silently means `default`) → same
   hang; the engine shows a node in another pool. `inspect engine`: the actor's pool has no node.
3. **onCreate throws** → caller gets `actor_stopped_while_waiting` in ~0.4 s; node logs `actor start failed`
   with rising generation numbers. Fix the hook's input or code.
4. **A workflow step throws until its retries are exhausted** → the actor still answers reads (looks healthy);
   only a node **warn** line `workflow failed and will sleep until woken … StepExhaustedError`. Made Well's
   `onError` turns it into a held run with the reason: `inspect run` shows the hold.
5. **Wrong token on the node** → the node exits 1 at start with `core.internal_error`; the real cause
   (`401 invalid_token` while upserting its pool) is only in `metadata.error`. `inspect service node`, `logs`.

Also seen live: an engine stopped by SIGTERM can fail-stop at its own 5 s singleton deadline (old engine 3.0.6:
`singleton services did not stop before the stop deadline`), leaving volumes "fenced; its owner must reopen" —
see `~/backups/rivet-snapshot-2026-11-15/FENCED-VOLUMES.md`. Never force-stop the live engine to back it up.

## Order of looking (fastest truth first)

1. `mw inspect health` — is the record being written (capture queued/spooled), engine up, nodes connected?
2. `mw inspect run <id>` — the facts, in order: the hold or error usually names its cause.
3. `mw inspect actor` / `engine` — vendor-level reading for Pending/Crashed.
4. `mw inspect logs` / `errors` / `spans` — only when the record does not say why.

Vendor references, pinned (rivet-dev/skills at the commit in `references/vendor/COMMIT`):
`references/vendor/rivet-actors.md`, `rivet-workflows.md`, `rivet-agentos.md`; and rivet.dev/docs:
tracing, debugging, troubleshooting, statuses, logging, deploy/self-host/control-plane/backups.
