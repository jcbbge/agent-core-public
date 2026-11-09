---
name: spine
description: One append-only event stream of what every agent does.
---

# spine — one event stream for every agent

Two files. No daemon, no database, no vendor.

| File | What |
|---|---|
| `spine-emit` | the only writer. Reads one event as JSON on stdin and appends one line to `$SPINE_DIR/<UTC date>.ndjson`. Never blocks, never prints. |
| `spine` | the reader: `spine tail [-f]`, `spine who`, `spine json`, with filters `--lane --role --scope --sid --repo --since`. |

Every line carries `ts h sid ag role lane scope cwd ev tool k arg path`:
- `role`, `lane` and `scope` come from the environment: `AGENT_ROLE`, `AGENT_LANE` and `AGENT_SCOPE`.
- `ag` is set for a sub-agent.
- `k` classifies the act as `read`, `search`, `write`, `exec` or `other`.

Agents never call either tool. They just work, and the stream records it.

The line format is the contract; how a harness's events become lines is not. The bundled
`spine-emit` reads one harness's event shape (`hook_event_name`, `tool_name`, `tool_input`,
`session_id`, `agent_id`, `cwd`) and maps its tool names to `k`. On any other harness, adapt that
mapping or write a writer that produces the same line. `k` must be `search` only for pattern or
file-name searches whose `arg` is `<pattern> <path>`; `ground` relies on it.

## Wiring

Put `spine` on PATH. Pipe every **session-start**, **prompt**, **after-tool**, **stop** and
**session-end** event into `spine-emit`.

`SPINE=off` disables it. `SPINE_DIR` moves it. At each session start it keeps
`SPINE_KEEP_DAYS` (14) days of files and drops Ground passes older than two days.
