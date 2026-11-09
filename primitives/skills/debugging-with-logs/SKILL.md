---
name: debugging-with-logs
description: Implement durable structured observability after a debugging investigation shows that existing evidence is insufficient. Use for canonical events, trace enrichment, field schemas, sampling, and retention—not as the generic entry point for diagnosing a bug.
license: MIT
metadata:
  version: "2.0"
---

# Durable Observability with Wide Events

This is a specialist implementation skill. Use `debugging` to choose an investigation route first. Use this skill only when the durable system needs better evidence after the smallest existing query, trace, source read, or metric cannot provide it.

## Outcome

Emit one structured event per meaningful request or operation, enriched across its lifecycle and queryable by stable correlation fields. The event is a maintained product surface: schema, privacy policy, sampling, retention, and ownership are part of the implementation.

## Design the event

1. Name the operation and the question the event must answer.
2. Define an explicit **field allowlist**. Fields not on the allowlist are dropped, not serialized opportunistically.
3. Include stable technical context where useful: event name, timestamp, request or trace ID, service, version, deployment, outcome, status, duration, and bounded error code.
4. Add only business context required for the named question. Prefer categories, booleans, counts, and internal opaque identifiers over raw values.
5. Build the event through the operation and emit once at its boundary. Preserve correlation across services through request or trace IDs.
6. Define tail sampling and retention deliberately. Keep failures and relevant slow operations; sample ordinary successes according to cost and diagnostic need.
7. Test schema shape, redaction, field rejection, emission on success and failure, and sampling behavior.

## Sensitive-data constraints

- Never log credentials, access tokens, session secrets, authorization headers, cookies, private keys, payment details, or secret-bearing URLs.
- Never log raw request or response bodies, arbitrary objects, environment dumps, database rows, or exception locals.
- Treat names, email addresses, phone numbers, addresses, message content, user-entered text, and precise location as sensitive. Exclude them unless a documented requirement, authorization, and retention policy explicitly permit the field.
- Prefer opaque IDs, hashes with an approved threat model, redacted excerpts, enums, and aggregate counts. Hashing low-entropy personal data does not make it anonymous.
- Sanitize error messages and stack metadata before emission. Third-party messages can contain payload fragments or secrets.
- Apply allowlisting and redaction at the event boundary so callers cannot bypass them by attaching extra context.
- Keep client telemetry stricter than server telemetry: URLs, referrers, DOM text, and device attributes can contain sensitive data.

## Implementation shape

```javascript
const ALLOWED_FIELDS = new Set([
  "event", "timestamp", "request_id", "service", "version",
  "outcome", "status_code", "duration_ms", "error_code",
]);

function emitOperationEvent(candidate) {
  const event = Object.fromEntries(
    Object.entries(candidate).filter(([key]) => ALLOWED_FIELDS.has(key)),
  );
  telemetry.emit(event);
}
```

The real implementation should use the project's telemetry transport and schema conventions. Do not introduce a new logging dependency when the existing stack can carry the event.

## Sampling

Sample after the outcome is known:

- retain error outcomes needed for operations and diagnosis;
- retain slow operations at an agreed threshold;
- retain explicitly monitored rollout cohorts without attaching sensitive cohort data;
- probabilistically sample routine successful operations;
- apply rate limits so an incident cannot create an unbounded telemetry or cost event.

Sampling is not a privacy control. Every retained or dropped candidate must pass the same allowlist and redaction boundary.

## Verification

- Query one emitted event by request or trace ID.
- Confirm required fields are present and unapproved fields are absent.
- Exercise success, expected failure, unexpected failure, and slow-operation paths.
- Seed representative sensitive values and prove they do not reach the sink.
- Verify sampling and rate limits without relying on production traffic.
- Document event owner, schema, retention, and the operational question it answers.

Do not ask users to disclose raw logs when a local query, redacted excerpt, aggregate, or yes/no check can answer the question.
