---
name: graphiti-memory
description: "Temporal knowledge graph memory: entities, relationships and episodes, with when each was true."
---

# MCP — graphiti-memory

Temporal knowledge graph (FalkorDB). Entities, relationships and episodes with time: what was
true, and when.

| | |
|---|---|
| Transport | HTTP, at `$GRAPHITI_MCP_URL` (a local Graphiti MCP server, e.g. `http://localhost:8001/mcp/`); stdio-only harnesses bridge with `npx -y mcp-remote $GRAPHITI_MCP_URL` |
| Source | Graphiti (upstream, open source) |

**When to use:**
- Cross-session memory ("what did we decide about X last week?")
- Storing decisions, findings, preferences that persist across conversations
- Building context about a project's evolution over time
- Searching for stored knowledge that isn't in files

**When NOT to use:**
- Code search → use `colgrep` or `rg`
- File-based documentation → use files directly
- Real-time data → use APIs
- Temporary session context → use normal conversation

## MCP Tools

The server is reached at `$GRAPHITI_MCP_URL`.

### search_nodes
Search the knowledge graph for entities matching a query.
```
search_nodes
  query: "what we decided about auth"
  group_ids: ["billing"]           # optional: filter to project namespace
  max_results: 10
```

### search_facts
Search for specific facts/relationships between entities.
```
search_facts
  query: "database migration strategy"
  group_ids: ["billing"]
```

### add_memory
Store an episode — a piece of information extracted into entities and relationships.
```
add_memory
  episode_text: "We decided to use Drizzle ORM for the billing database layer, choosing it over Prisma for type safety and migration control."
  group_id: "billing"
  source: "session-notes"
```

### delete_entity / delete_episode
Remove specific entities or episodes from the graph.

### clear_graph
**Dangerous.** Clears all data for a group. Use only when explicitly asked.

## group_id Convention

Group IDs namespace the graph per project. Use bare project names:

| Project | group_id |
|---|---|
| A project named billing | `billing` |
| General / cross-project | `main` |

When adding memory, always specify the project's group_id. When searching, omit `group_ids` to search across all projects, or specify one to narrow results.

## Operational Details

| Detail | Value |
|---|---|
| MCP endpoint | `$GRAPHITI_MCP_URL` |
| FalkorDB | the graph database Graphiti runs on |
| Health check | `graphiti health` |
| CLI | `graphiti` on PATH (a wrapper around the Graphiti containers) |

### Start / Stop / Restart

```bash
graphiti up          # start (with health wait)
graphiti down        # stop
graphiti restart     # restart
graphiti rebuild     # rebuild after git pull
graphiti logs        # follow logs
graphiti status      # container status
graphiti health      # health check
```

### Verify it's working

```bash
graphiti health
# → {"status":"healthy","service":"graphiti-mcp"}
```

## Data Model

Graphiti extracts **entities** (nodes) and **relationships** (edges) from text. Entity types include:

- **Preference** — user choices, opinions (prioritized)
- **Requirement** — features, constraints that must be met
- **Procedure** — step-by-step instructions
- **Event** — time-bound occurrences
- **Organization** — companies, groups
- **Document** — reports, articles, specs
- **Topic** — knowledge domains (last resort)
- **Object** — tools, devices (last resort)

Each entity has a `created_at` and `valid_at` timestamp. Relationships between entities are also temporal — the graph knows when a relationship started and whether it's still valid.

## Model endpoints

Graphiti needs a chat model endpoint (entity extraction) and an embeddings endpoint (vector
search), set in its own server config. Which models serve them is the environment's choice.
