---
name: ast-grep
description: Structural code search by syntax shape (tree-sitter patterns with metavariables). Use when a regex cannot express the match, such as call shapes, argument shapes or nested constructs across a repo. Search by default; rewrite only as a deliberate edit.
---

# ast-grep — search by code shape

Binary: `ast-grep` on PATH. Source: https://github.com/ast-grep/ast-grep (`brew install ast-grep`, or `npm install -g @ast-grep/cli`). Any repo, any harness. Present when `ast-grep --version` answers.

Some installs also provide the short name `sg`; on Linux `sg` is also the system's setgroups command, so always call `ast-grep`.

## When

- Find code by its syntax shape across files: call patterns, argument shapes, nested constructs, where a regex over-matches or cannot be written.
- `$A` matches any single node; `$$$ARGS` matches any list of nodes.
- Any language ast-grep has a tree-sitter grammar for. JS/TS is the common case; PHP is supported too.

## When not

- Exact string or regex → `rg`.
- Meaning search without a known identifier → `colgrep`.
- Callers, callees or impact of a symbol → `coraline`.
- Map or skeleton of one file → `composto`.

## How

```bash
ast-grep run -l ts -p 'eval($A)'
ast-grep run -l ts -p 'console.log($$$ARGS)'
ast-grep run -l ts -p 'eval($A)' --json    # matches as JSON
```

Search is the default use. `--rewrite`/`-r` alone only previews the change as a diff. `-U`/`--update-all` applies every rewrite without asking, so it is an edit to the working tree: run it only as an intended change and review it like any other edit. `-i`/`--interactive` prompts per match and is for a human at a terminal; an agent never uses it.

Do not go through a search router. Call this binary.
