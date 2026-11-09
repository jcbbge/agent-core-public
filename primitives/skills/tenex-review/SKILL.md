---
name: tenex-review
description: Perform an on-demand complexity-only code review over a diff, named file, or whole repository. Use when asked to find over-engineering, unnecessary abstractions, avoidable dependencies, duplicated local patterns, dead flexibility, code that should use the standard library or native platform, or opportunities to delete and shrink code. Supports diff, file, and repo scope. Reports findings only and does not apply fixes or replace correctness, security, accessibility, performance, or project-policy review.
---

# Tenex Review

Review only unnecessary complexity. Do not apply fixes.

## Scope

Select the narrowest scope requested:

- **diff** — review the supplied or current working diff; default when no scope is named
- **file** — review only the named file or files
- **repo** — inspect the repository and rank actionable complexity findings

For repo scope, inspect project structure, dependencies, repeated patterns, thin
wrappers, speculative extension points, and local conventions. Do not mistake a
large codebase for an over-engineered one.

## Standard

Evaluate candidates against this ladder:

1. necessity
2. codebase reuse
3. standard library
4. native platform
5. existing dependency
6. minimum custom code

Repository-local idiom and legibility to a proficient maintainer outrank code
golf or line density.

Before reporting a finding, identify the concrete replacement and verify that it
preserves behavior. Do not report vague preferences.

## Tags

- `delete:` dead code, speculative behavior, unused flexibility, or a layer with no remaining purpose
- `stdlib:` custom code replaced by a named standard-library facility
- `native:` code or dependency replaced by a named platform, framework, browser, database, or protocol feature
- `yagni:` configuration, abstraction, factory, interface, or extension point unsupported by a current requirement
- `shrink:` the same behavior expressed with materially less clear code surface
- `local-pattern:` custom machinery replaced by a demonstrated nearby repository pattern

Use `local-pattern` only when the replacement already exists in the repository;
name where.

## Output

List findings in descending impact:

`[tag] <path>:L<start>-L<end> — <complexity to remove>. Replace with <concrete replacement>.`

Examples:

```text
[local-pattern] src/jobs.ts:L42-L71 — second retry loop with different edge behavior. Replace with runWithRetry from src/runtime/retry.ts.
[stdlib] src/config.py:L18-L39 — custom query-string parser. Replace with urllib.parse.parse_qs.
[yagni] src/store.ts:L7-L28 — repository interface with one implementation and no alternate requirement. Use SqlStore directly.
[delete] src/cache.ts:L55-L63 — unused configurable eviction branch. Remove it.
```

For repo scope, group findings by impact only when that improves readability.
Do not invent line-savings totals.

If no actionable complexity finding exists, output:

`Lean for this scope.`

## Boundaries

Do not flag or recommend removing:

- requested behavior
- security or safety controls
- trust-boundary validation
- data-loss prevention
- accessibility
- repository invariants
- tests or checks required by project policy
- abstractions justified by current multiple implementations or callers
- complexity required by measured performance constraints

Correctness, security, accessibility, and performance defects belong in their
own review passes. Mention one only when a proposed simplification would violate
it; otherwise stay within complexity scope.
