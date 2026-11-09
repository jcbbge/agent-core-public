---
name: secure-build
description: The security standard to build against, for any language or stack. Hard laws plus one standard per surface (API, database, sign-in, webhooks, MCP server, telemetry and switches). Each standard pairs the rules to build to with the measurements that prove them. Use before and while building or changing an endpoint, API, MCP server, database access, sign-in flow, webhook, or anything that faces the network; then check the result with the security-audit skill.
---

# Secure build

**Read this before you build. Check against it when you are done.** The standards are the rules
you build within. Each rule comes with a *Measure* line: the test that proves the rule holds.
"Done" means every applicable measure passed against the running system.

## Laws (every surface, no exceptions)

1. **Deny by default.** Nothing is reachable, readable or writable until a rule allows it.
2. **The server decides.** Business logic, authorization and data access run on the server, and nothing the client says about identity or permission is trusted. (Rule: `backend-first-security`.)
3. **Authenticate, then authorize, then work.** Every request is checked for who it is *and* whether it may touch *this object*, before any data access.
4. **Validate at the boundary.** Every input is checked against a schema, with sizes capped, before use. Every output is shaped deliberately, never a raw database row.
5. **Least privilege everywhere:** for people, services, agents, database roles and tokens. Narrow scope, short life, one purpose.
6. **Secrets never enter code, logs, URLs, prompts or the client.** They are loaded at runtime from one place. (Rule: `secrets`.)
7. **Every cost has a bound:** rate, concurrency, size, time and rows. Over the bound means an immediate reject, never a queue.
8. **Everything you can see, you can switch off:** one event per decision, a live view, and a server-side switch. (Standard: `telemetry-and-switches.md`.)
9. **Fail closed.** If a check, a switch or a dependency can't be evaluated, the answer is no.
10. **Proven on the running system.** A rule counts only when its measure passed against the deployed thing. Reading the code is not proof.

## Standards (load each one that applies to what you are building)

| Building… | Load |
|---|---|
| Any HTTP endpoint or API | [standards/api.md](standards/api.md) |
| Anything that reads or writes a database | [standards/database.md](standards/database.md) |
| Sign-in, sessions, tokens, OAuth or OpenID Connect | [standards/auth.md](standards/auth.md) |
| Receiving webhooks | [standards/webhooks.md](standards/webhooks.md) |
| An MCP server (also load the API, database and auth standards) | [standards/mcp-server.md](standards/mcp-server.md) |
| Anything (logging, live view, kill switches) | [standards/telemetry-and-switches.md](standards/telemetry-and-switches.md) |

When the project's own rules are stricter, follow them. When they conflict with a standard here,
report the conflict to whoever gave you the work. Never resolve it silently in either direction.

## How to use it

1. **Before building:** list the surfaces you will touch and load their standards. Write down the invariants (things that must never be true) next to the code.
2. **While building:** treat each rule as a requirement. Write the test for its *Measure* line as you build, not afterwards.
3. **When done:** run the `security-audit` skill in change mode. Report every applicable measure as `PASS`, `FAIL`, `N/A` or `UNKNOWN`, each with evidence from the running system. A missing measurement is `UNKNOWN`, never `PASS`.

## Handing this to an agent

Paste and fill in:

```
Build <thing> in <repo>. Scope: <what is in>; out of scope: <what is not>.
Before and while building, follow the secure-build skill: its laws, plus the standards
for <surfaces>. The project's own rules win where they are stricter; report any conflict
with the skill to me instead of resolving it yourself.
When done, run security-audit in change mode against the deployed <thing> and report each
applicable measure as PASS/FAIL/N/A/UNKNOWN with evidence. Not done until every FAIL is fixed
and every UNKNOWN is either measured or named to me with what would settle it.
```
