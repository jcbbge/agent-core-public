---
name: coraline
description: Local code-intelligence graph for any repo — symbols, callers, callees, impact, context. Use BEFORE Grep/Read for "who calls X", "what breaks if I change Y", cross-file symbol navigation. 33 languages. Not limited to zig or any two repos — init+index the tree you are in.
---

# coraline — symbol graph

Binary: `coraline` on PATH. Source: https://github.com/greysquirr3l/coraline (`cargo install coraline`). Any repo, any harness. CLI only.

## When

- Cross-file: callers, callees, impact radius, "where is this symbol."
- Unfamiliar or large trees where grep will dump noise.
- After `coraline init` + `coraline index` in that tree (an existing index lives in `.coraline/`).

## When not

- Exact string/regex → `rg` / harness Grep.
- Meaning search without a symbol name → `colgrep`.
- Inside one 3k+ PHP/JS/TS file → `bigfile` MCP.
- Past sessions → `pickbrain`.

## How

```bash
coraline init              # once per repo
coraline index             # or sync after git changes
coraline query "<symbol>"
coraline callers <node-id>
coraline callees <node-id>
coraline impact <node-id>
coraline context "<task>"
```

Do not go through a search router. Call this binary.
