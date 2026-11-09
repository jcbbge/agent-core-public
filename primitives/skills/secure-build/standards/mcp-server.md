# Standard: a remote MCP server

An MCP server is also an API with a database and a sign-in flow, so `api.md`, `database.md` and
`auth.md` all apply. This file adds what is specific to MCP. For several MCP servers in one app,
each server gets its own audience, scopes, tool allowlist, database role and master switch, so
turning one off never affects the others.

Opinionated conventions for an MCP server reachable over HTTPS, written as gates to build against.
Written against MCP spec revision 2026-07-28 (authorization, security best practices, Streamable
HTTP). Clients in the field may still send older revisions: log the `MCP-Protocol-Version` header
you actually receive and support exactly those revisions.

## The shape

Two questions, kept separate:

- **Can someone send us a request?** Anyone on the internet can. That is normal. The goal is that a
  stranger's request costs almost nothing and reaches nothing.
- **Will we give them data?** Only when an audience-bound token that we issued, for a known person,
  with the right scope, asks for an allowed tool.

The MCP server is an **OAuth resource server**. Your app is the authorization server. Your identity
provider (Google, or any OpenID Connect provider) only proves who the person is. Your app then
issues its *own* token for the MCP endpoint. Never accept or forward the identity provider's
token. Because of this, the server is an MCP proxy in the spec's terms, so the confused-deputy
rules apply: per-client consent is required.

Edge filtering and DDoS services are whole-application concerns, not MCP prerequisites.
Everything below runs inside the app and its existing reverse proxy, so no vendor is required.

## Gates

Each gate states what to build and how to measure it. A gate passes only when its test ran
against the deployed endpoint.

### A. One entry point
- The MCP endpoint is one path on the existing HTTPS proxy. The app's own port listens only on loopback or a private interface.
  *Measure:* an outside port scan shows no new port, and a direct hit to the app port from outside fails.
- The client IP used for limits comes from the proxy's header, and the app trusts only the proxy hop.
  *Measure:* a forged forwarded-for header from outside does not change the IP the app records.
- An invalid `Origin` gets 403. The request body is size-capped. GET and DELETE on the MCP path get 405 (latest revision).
  *Measure:* a request with `Origin: https://evil.example` → 403; an oversize body → 413.

### B. Discovery (public, no session)
- Protected resource metadata is served at `/.well-known/oauth-protected-resource[/<mcp-path>]`, and its `authorization_servers` is not empty.
- A request with no token gets 401 with `WWW-Authenticate: Bearer resource_metadata="…", scope="…"`.
- The authorization server metadata (RFC 8414 or OIDC discovery) includes `code_challenge_methods_supported: ["S256"]`.
- Client registration: prefer Client ID Metadata Documents. Enable dynamic registration only if a client you target needs it. If you do, rate-limit it, cap its size, and expire registrations that are never used.
  *Measure:* a fresh client with no browser session can complete discovery from the 401 alone.

### C. Authorization
- Require PKCE `S256`. `redirect_uri` must match exactly. `state` is random, single-use and expires in about 10 minutes.
- **Per-client consent screen** before redirecting to the identity provider. It shows the client name, redirect host and scopes, with CSRF protection and anti-framing. The consent cookie uses the `__Host-` prefix, `Secure`, `HttpOnly` and `SameSite=Lax`, and is bound to `client_id`.
- Admission comes from the *verified* ID token: the issuer, audience, email-verified flag, organisation or domain claim, **and** a matching active user in your own user table. An email string supplied by the client never admits anyone.
- Include `iss` in the authorization response (RFC 9207).
  *Measure:* an org account connects; a non-org account and a disabled user are both refused; a replayed authorization code is refused.

### D. Tokens
- Opaque or signed, issued by you, with **audience = the canonical MCP URI**. Access tokens are short-lived (≤ 1 hour). Refresh tokens rotate, and **reusing one revokes the whole connection**.
- Stored hashed. Never in a URL query string. Never logged.
- The MCP token works only on the MCP endpoint. The browser session cookie does not work on the MCP endpoint.
  *Measure:* the MCP token is rejected by a normal API route; a browser cookie is rejected by the MCP endpoint; a token minted for another audience gets 401; a reused refresh token kills the connection.

### E. Every request, before any work
- Order: parse and size-check → authenticate (401) → authorize scope and tool (403 `insufficient_scope`) → only then touch data.
- A session or state handle is never authentication.
  *Measure:* missing, fabricated, expired and revoked tokens each fail `tools/list` and `tools/call`, and the database query log shows zero queries for them.

### F. Tools
- An allowlist of read-only tools. **Read-only is enforced by the database role used for MCP**, not only by code.
- Row scoping follows the caller's own permissions in the app.
- Every tool input is schema-validated. Outputs are size-capped. No tool fetches an arbitrary URL. Tool descriptions are static text.
  *Measure:* a write statement run as the MCP database role fails; a user sees only rows the app would show them.

### G. Budget (how strangers and heavy agents are contained)
- Per-IP limits on the unauthenticated endpoints: discovery, register, authorize and token.
- Per-connection limits on calls, a concurrency cap, and a statement timeout on the MCP database role.
- Over the limit means an immediate reject (429), never an unbounded queue.
  *Measure:* a bounded burst of invalid requests gets 429 while normal app pages stay responsive; a slow query is cancelled at the timeout.
- Out of scope, named as residual risk: floods that saturate the host's network. That belongs on the whole-system checklist.

### H. Observe and stop
Build to [telemetry-and-switches.md](telemetry-and-switches.md): one wide event per decision,
switches in the database, a live admin view, and alerts that name their switch. For MCP, map
it as follows:

| Gate | Watch (per minute, by reason) | Invariant (must be 0) | Switch / dial |
|---|---|---|---|
| All | requests, decisions, p95, in-flight | — | **MCP master off** (503; app unaffected) |
| A. Entry | origin rejects, oversize, by IP | hits on the app port from outside | IP block; body-size dial |
| B. Discovery | 401s, metadata fetches, registrations | — | **new connections off** (existing ones keep working); registration off |
| C. Authorization | consent shown/approved/denied, admissions refused by reason | admitted without a matching active user | authorize off; per-client block; per-user block |
| D. Tokens | issued, refreshed, revoked, active connections | refresh reuse not followed by revocation | refresh off; revoke one / revoke all |
| E. Request order | auth failures by reason | database queries for unauthenticated requests | (covered by master) |
| F. Tools | calls by tool, user and outcome; rows; bytes; database ms | write attempts by the MCP database role | **per-tool off**; output-size dial |
| G. Budget | 429s by limiter, concurrency in use, statement timeouts | — | rate dials (per IP, per connection); concurrency dial; timeout dial |

The order of response is always smallest switch first: one connection → one user or client →
one tool → new connections → master.

*Measure:* flip each switch in the table on the deployed endpoint and watch its effect in the
live view within 5 seconds; revoke one connection and its next call gets 401; trigger each
invariant once in staging and confirm the alert names the right switch.

## Release

Ship when every gate's measurement passed against the deployed endpoint, plus one real end-to-end
run: a real person connects a real client and gets data that matches the app's own figure for the
same record. Report anything unmeasured as UNKNOWN, and never claim "DDoS-proof".
