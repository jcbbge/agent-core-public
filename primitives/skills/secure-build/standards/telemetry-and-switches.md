# Telemetry and switches

The rule: **every surface you can see, you can switch off.** When something alerts or looks
wrong, you turn off the smallest switch that stops it in seconds, then read the evidence at
leisure, then turn it back on. This pattern applies to any surface. A standard (such as
`mcp-server.md`) lists the specific metrics and switches for its gates.

No vendor is required: events and switches live in your own database, and the live view is a
page in your own app. Anything else, such as an observability backend or a paging service, is an
optional export over an open format.

## Events: one wide event per decision

Each request writes one structured event (a "canonical log line") at the end. Every field is in
it, so a single row answers "what happened":

```
ts  trace_id  surface  gate  decision  reason  status  latency_ms
ip  client_id  user_id  connection_id  tool  rows  bytes_out  db_ms  limiter  switch_state
```

- `decision` is one of `allow`, `deny`, `throttle`, `error` or `switched_off`. `reason` is a short fixed code such as `token_expired`, `wrong_audience`, `origin_invalid` or `refresh_reuse`. Never use free text.
- **Never stored:** tokens, codes, secrets, request or response payloads, or personal data beyond the IDs above.
- `trace_id` follows a request from the proxy through the app into the database (W3C `traceparent`), so one row leads to the whole trace.
- Events go into your own database first (an append-only table). Exporting them over OpenTelemetry to any backend is optional and swappable.
- Retention is fixed and written down (for example 30 days of events and 1 year of switch and audit history).

## Metrics: counters derived from the events

For each gate, keep counts per minute of each `decision` by `reason`, plus p50/p95 latency,
in-flight concurrency and active connections. Expose them in an open text format (the Prometheus
exposition format) at an internal-only path. **Invariant metrics** must always be zero, and any
non-zero value is an alert by itself.

## Switches

- **Stored server-side in your database, never in environment variables.** A switch that needs a deploy is not a switch.
- **Read on every request**, cached for at most 5 seconds. A flip takes effect everywhere within that time.
- **Fail closed:** if the switch store can't be read, the surface is off.
- **Sizes:** a master switch for the whole surface, one switch per gate or feature, one per tool, a block per client, user or IP, and revocation per connection. Limits are **dials** (numbers in the same store) as well as switches, so you can tighten without turning off.
- **Every flip is audited:** who, when, from what state to what state, and why (a required one-line reason).
- **The control is protected separately:** only admins can use it, through the browser session, with rate limits. A surface's own credential can never flip a switch, so an MCP token can't turn MCP back on.
- **Break-glass:** a documented command on the server flips any switch through the database directly. It works when the app's admin page doesn't.
- **What a switched-off surface returns:** a clear status (503 for a surface that's off, 401 for a revoked credential) with a `reason`, and an event with `decision=switched_off`.

## The live view

One admin page, with real-time updates (polling every few seconds is enough):

1. **Switch panel:** every switch and dial, its state, and who flipped it last and why. One click to flip, with a reason required.
2. **Gate tiles:** per gate, allow, deny and throttle in the last 5 minutes against the baseline, with invariant metrics in red when they are non-zero.
3. **Live tail:** the event stream, filterable by gate, decision, reason, client, user, connection or IP. Clicking a row opens its full trace.
4. **Alerts:** each alert that fires names **the switch to flip** for it.

## Alerts

Keep them few, each with an owner and a named switch. Defaults:

- Any invariant metric is non-zero → page now.
- A denial rate several times the baseline, sustained for minutes → notify.
- Throttling sustained, or concurrency at its cap → notify.
- Error rate or p95 latency over its threshold → notify.

An alert you ignore twice gets tuned or deleted.

## Gates for this pattern

- *Measure:* flip each switch on the deployed system. Its effect appears within 5 seconds, unrelated surfaces are unaffected, and the flip appears in the audit history.
- *Measure:* with the switch store made unreadable, the surface is off.
- *Measure:* the break-glass command works with the app's admin page down.
- *Measure:* a full search of stored events finds no token, code or secret.
- *Measure:* a test alert reaches the human and names its switch.
