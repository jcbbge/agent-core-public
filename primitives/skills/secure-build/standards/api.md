# Standard: HTTP endpoints and APIs

Covers any route that takes a request over the network. These rules map to the OWASP API
Security Top 10 (2023); its most common failure is broken object-level authorization.

### 1. Inventory
- Every route is listed in one place (the router or a spec), with its owner, its authentication and its purpose. A route that isn't listed doesn't ship. Old versions and debug routes are deleted, not just hidden.
  *Measure:* a route list taken from the running app matches the inventory exactly.

### 2. Authentication on every route
- Routes are authenticated by default. A public route is an explicit, listed exception.
  *Measure:* every non-public route returns 401 with no credential, and with a fabricated or expired one.

### 3. Authorization on every object
- On every read and write, check that *this* caller may act on *this* object (by owner, tenant or role), loaded on the server. Never trust an ID or role the client sends.
- Function-level: admin and internal actions are separate routes with their own role check.
- Property-level: the client can write only an allowlist of fields. The response contains only an allowlist of fields.
  *Measure:* user A requesting user B's object by ID gets 404 or 403; a normal user calling an admin route gets 403; sending an extra field (`role`, `owner_id`) changes nothing.

### 4. Input
- Schema-validated: types, formats, enums, lengths and ranges. Unknown fields are rejected. The body size is capped at the proxy and in the app.
- No input is concatenated into SQL, shell commands, paths, templates or URLs. Use parameters, allowlists and builders.
- An endpoint that fetches a URL validates it against an allowlist of hosts and blocks private and internal address ranges at resolution time (to prevent server-side request forgery).
  *Measure:* malformed input, an unknown field and an oversize body each get 400 or 413; an internal address submitted as a URL is refused.

### 5. Output and errors
- Errors use one shape (Problem Details, RFC 9457) with a fixed code. No stack traces, SQL or internal paths reach the client.
- Lists are always paginated, with a maximum page size enforced on the server.
  *Measure:* a forced server error returns the generic shape; requesting `limit=100000` returns at most the maximum.

### 6. Resource bounds
- Rate limits per IP on public routes, per principal on authenticated ones, and tighter on sign-in and other expensive or state-changing routes. Over the limit gets 429 with `Retry-After`.
- Timeouts on every outbound call and every query. Caps on concurrency and on sensitive business flows (sign-ups, sends, exports).
  *Measure:* a burst gets 429 before it degrades other routes; a slow dependency times out within its budget.

### 7. State-changing requests
- Writes that may be retried accept an `Idempotency-Key`, so a replay returns the first result and never a second write.
- With cookie sessions: SameSite cookies, plus CSRF protection on every state-changing route.
  *Measure:* the same idempotency key twice produces one write; a cross-site form post is refused.

### 8. Browser-facing configuration
- CORS: an explicit list of allowed origins, never a wildcard together with credentials.
- Headers: HSTS, `X-Content-Type-Options: nosniff`, a restrictive Content-Security-Policy, and `frame-ancestors` set.
- TLS only. Plain HTTP only redirects to HTTPS.
  *Measure:* a disallowed origin gets no CORS grant; the headers are present on a deployed response.

### 9. Calling other APIs
- Treat their responses as untrusted input: validate them, bound them and time them out. Pin the hosts.
  *Measure:* a malformed upstream response produces a handled error, never a crash or a pass-through.
