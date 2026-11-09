---
name: circadian
description: "Cross-session memory: recall at session start, store what a future session could not re-derive."
---

# MCP — circadian

Cross-session memory. Recall at session start, store what a future session could not re-derive
(the directive's "Memory" section). Tools: `memory_view`, `memory_recall`, `memory_search`,
`memory_read`, `memory_expand`, `memory_history`, `memory_status`, `memory_request_change`.

| | |
|---|---|
| Transport | stdio |
| Command | `bun <circadian>/src/serve.ts` |
| Env | `CIRCADIAN_HOME` — the circadian checkout |
