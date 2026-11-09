---
name: tenex-debt
description: "Read and report deliberate simplification markers of the form `tenex: current ceiling; factual upgrade trigger` across a codebase. Use when asked for Tenex debt, simplification debt, deliberate shortcuts, current implementation ceilings, deferred upgrades, or a ledger of `tenex:` comments. Produces a one-shot read-only report and flags missing or non-factual triggers."
---

# Tenex Debt

Collect deliberate Tenex simplifications into a read-only ledger. Do not modify
code or create a ledger file unless separately asked.

## Marker contract

A valid marker is a source comment containing:

`tenex: <current ceiling>; <factual upgrade trigger>`

The ceiling states the present limitation. The trigger states an observable
condition that justifies revisiting it.

Valid triggers include:

- a second implementation is accepted
- a measured threshold is crossed
- a named dependency is adopted
- a supported platform version changes
- a documented invariant no longer holds

“Later,” “if needed,” “at scale,” and similar phrases are not factual triggers.

## Scan

Search source comments recursively while excluding version-control metadata,
dependencies, generated output, and build output. Adapt comment prefixes to the
languages in the repository.

Example:

```sh
rg -n --hidden \
  --glob '!.git/**' \
  --glob '!node_modules/**' \
  --glob '!vendor/**' \
  --glob '!dist/**' \
  --glob '!build/**' \
  '(#|//|--|/\*|\*)\s*tenex:' .
```

Exclude prose that merely documents the convention. Include only comments
attached to implementation decisions.

## Classify

For each marker:

- `valid` — contains a current ceiling and factual trigger separated by `;`
- `no-trigger` — omits the trigger
- `non-factual-trigger` — supplies only a vague intention or date-free promise
- `malformed` — cannot be parsed into ceiling and trigger

Do not infer missing information from nearby code.

## Output

Group markers by file:

`<path>:<line> [<status>] ceiling: <current ceiling>; trigger: <upgrade trigger or UNKNOWN>`

End with:

`<N> markers: <V> valid, <T> no-trigger, <F> non-factual-trigger, <M> malformed.`

If none exist:

`No tenex: debt markers found.`

## Boundaries

This skill reports explicit markers; it does not perform a general complexity
audit, propose refactors, apply fixes, or decide that a trigger has been met.
Use `tenex-review` for complexity review.
