---
name: security-audit
description: Run a bare-bones, stack-agnostic security check on a change or a whole system. Ten layers, one pass/fail check per line, evidence or UNKNOWN. Use before shipping a change that adds a surface (endpoint, webhook, tool, credential, dependency, port, role), on a regular rhythm across the whole system, or when asked "is this secure", "security audit", "security checklist".
---

# Security audit

Security is never done, only better: the goal is "more secure than yesterday", and secure mostly
means the system keeps its promises under attack. The checks below are the policy. Tools are
swappable plug-ins that make a check pass; changing a tool never changes the policy.

## Two modes

- **Change**: scoped to one diff or feature. Check every *Measure* line in the `secure-build`
  standards for the surfaces the change touches, plus the checklist layers below that it touches.
  Do this before reporting any change done that adds or alters a surface.
- **System**: every layer below, across every app, machine, server, database and agent, plus the
  standards for each surface that exists. Do it on a regular rhythm and after any incident.

The rules being checked live in the `secure-build` skill (`standards/`). This skill holds no
second copy of them.

## How to answer each line

Each check is `PASS`, `FAIL`, `N/A` or `UNKNOWN`, and each comes with its evidence: a command run,
a file read or a test this session. No evidence means `UNKNOWN`, never `PASS`. An `UNKNOWN` is a
finding. For a `secure-build` measure, the evidence must come from the running system, not from
reading code.

## The checklist

**0. Design**
- [ ] Every new surface has a note covering: what it is, what could go wrong, what we do about it.
- [ ] The invariants (things that must never be true) are written down where the code lives.

**1. Code**
- [ ] No secret in the code or its history. A scanner runs before commit and again at the gate.
- [ ] Static analysis runs at the gate. Every high finding is fixed or dismissed with a reason.
- [ ] Dependencies are pinned, with no known critical vulnerability in code that runs. They are updated on a regular rhythm.

**2. Build and deploy**
- [ ] The deployed artifact holds only files on an allowlist: no env files, keys or dev config.
- [ ] Deploys come only from the trunk, from a clean tree, with secrets loaded at runtime.

**3. Infrastructure**
- [ ] An outside scan of each public address matches the written list of expected ports.
- [ ] Databases are not public, require TLS, and give each service its own least-privilege role. No app runs as superuser.
- [ ] Secrets live in one runtime-loaded place and can be rotated without a code change.
- [ ] A backup was restored successfully within the last quarter.
- [ ] OS, runtime and image packages are current.

**4. Machines** (every computer that holds a credential)
- [ ] Disk encryption, automatic updates, firewall and screen lock are on.
- [ ] Each machine has a list of the credentials it holds and how to revoke them if it is lost.

**5. Identities** (people, users, services)
- [ ] Every account that can deploy, pay, change DNS or read production data uses phishing-resistant MFA.
- [ ] Sign-in checks the token's issuer, audience and expiry, and asks for the smallest scope. Identity is never taken from the client's word.
- [ ] Authentication is rate-limited. Bursts of failures followed by a success are logged.
- [ ] Every principal is listed with its permissions. Anything no one can justify is revoked.

**6. Agents** (models, harnesses, tool servers, workers)
- [ ] Each agent's reach is written down: what it reads, writes, spends, and where its output goes.
- [ ] Agents hold narrow, short-lived credentials. None holds production-write or deploy credentials by default.
- [ ] Tool servers are pinned, reviewed, and get only the credentials their tools need.
- [ ] Irreversible actions need a human yes, enforced by a guard and not by an instruction.
- [ ] Untrusted content (web pages, issues, files, tool output) cannot steer an agent into a write path.
- [ ] Secrets and customer personal data never go into a prompt sent to an outside provider.

**7. Interfaces** (API, webhooks, tool endpoints)
- [ ] Every input is validated against a schema at the boundary.
- [ ] Every webhook's signature is verified. Replays are rejected by timestamp or nonce.
- [ ] Every endpoint that changes state is rate-limited and requires authorization on the server.
- [ ] The client never reaches the database. All business logic runs on the server.
- [ ] Each check above was run against the *deployed* system, not just read in code.

**8. Events**
- [ ] Sign-ins, permission changes, admin actions, deploys, webhook failures and agent tool calls are logged in an open format.
- [ ] Secrets and personal data are scrubbed from logs before storage.
- [ ] Every alert has an owner and names the switch that stops it. Noisy alerts are tuned or deleted.
- [ ] Every surface has an off switch stored server-side that takes effect in seconds, fails closed and is audited.
- [ ] A decoy (a credential or record nothing should touch) alerts when touched.
- [ ] A one-page response plan exists (revoke, rotate, restore, notify), and one key has been rotated end to end as a drill.

**9. Vendors**
- [ ] Each provider is listed with the data it holds, the access it has, and a written way to leave it.
- [ ] The data each provider holds also exists in a portable form you control.

## Report

```
Security audit — <change|system> — <scope> — <date>
FAIL      <layer.line> <what> — evidence — fix
UNKNOWN   <layer.line> <what> — what would settle it
PASS      <count>   N/A <count>
Next: <the single most important fix>
```

List FAILs first, ordered by blast radius. Fix what is in scope. Route everything else to whoever
owns it. Never mark the audit passed yourself: a re-run by someone else, or a test, closes it.

## Order, when starting from zero

Secrets and identity → agent reach → exposure and databases → interfaces → code gates → events
and restore drill → design habit and vendor exits.
