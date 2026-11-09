---
name: tenex
description: Apply a bounded implementation-craft loop that minimizes unnecessary code without sacrificing correctness, safety, validation, accessibility, requested behavior, or project verification policy. Use for coding tasks that add, change, fix, refactor, or design implementation; when asked for the simplest maintainable solution; or when avoiding over-engineering, speculative abstractions, boilerplate, and unnecessary dependencies. Prefer repository-local idiom and legibility to a proficient maintainer over code golf. Use tenex-review instead for review-only requests.
---

# Tenex

Implement the smallest maintainable change that fully satisfies the task.

## Non-negotiables

Do not simplify away:

- requested behavior
- safety or security controls
- validation at trust boundaries
- error handling that prevents corruption or data loss
- accessibility
- repository invariants
- tests and checks required by project policy

Prefer repository-local idiom and legibility to a proficient maintainer over
code golf, density, novelty, or the fewest possible characters.

## Loop

Run one bounded loop:

1. Preflight
2. Narrowly implement
3. Craft review
4. Apply at most two material refinements
5. Run the project-required verification

### 1. Preflight

Before editing:

- Read the task, applicable project instructions, and the affected code.
- Trace enough of the real flow to identify the correct change point.
- Inspect nearby code for an established local pattern.
- Identify requested behavior, protected concerns, and required verification.
- For a bug, locate the root cause and shared correction point rather than
  patching only the reported symptom.

Then walk the simplification ladder. Stop at the first rung that fully holds:

1. **Necessity** — omit work that is neither requested nor required.
2. **Codebase reuse** — reuse an existing local helper, type, component, or pattern.
3. **Standard library** — use the language runtime’s supported facility.
4. **Native platform** — use the browser, operating system, database, framework, or protocol feature.
5. **Existing dependency** — use a dependency already owned by the project.
6. **Minimum custom code** — write the smallest clear local implementation.

Explicit requirements are not speculative. Do not silently discard them at the
necessity rung.

### 2. Narrowly implement

- Make the smallest coherent diff at the correct abstraction level.
- Match local naming, control flow, file placement, and error-handling style.
- Prefer deletion and direct code over new layers.
- Do not add speculative configuration, extension points, wrappers, factories,
  interfaces, helpers, files, or dependencies.
- Do not refactor unrelated code.
- Keep an abstraction when the repository already relies on it or the task
  demonstrably needs it.

If a deliberate simplification has a real operating ceiling, mark it beside the
code:

`tenex: <current ceiling>; <factual upgrade trigger>`

Examples:

```text
# tenex: linear scan over active jobs; replace with an index when measured lookup latency exceeds the project budget
// tenex: one backend implementation; introduce an interface when a second backend is accepted
```

Do not add a marker for ordinary clean code. A trigger must be observable, not
“later,” “if needed,” or “at scale.”

### 3. Craft review

Reread the resulting diff as a proficient maintainer:

- Is every added concept necessary?
- Does existing code or a higher ladder rung replace custom code?
- Does the change follow the clearest nearby local pattern?
- Can a branch, layer, dependency, file, or duplicate path disappear?
- Are names and control flow immediately legible?
- Did simplification weaken a protected concern?

### 4. Refine, then stop

Apply at most two material refinements from the craft review.

A material refinement removes or consolidates meaningful complexity, aligns the
change with a demonstrated local pattern, or makes behavior substantially easier
to understand. Cosmetic churn and preference-only rewrites do not qualify.

After two material refinements, stop optimizing. Corrections required for
correctness, protected concerns, or failed verification are mandatory and do not
count as optional craft refinements; fix them without reopening an unbounded
polish loop.

### 5. Verify

Run the checks required by the repository and task. Do not replace project
verification policy with a smaller Tenex-specific check. Report checks actually
run and any that could not run.

## Response

Report:

- what changed
- any meaningful complexity intentionally avoided
- verification performed
- any `tenex:` ceiling introduced

Keep the report proportional to the task.
