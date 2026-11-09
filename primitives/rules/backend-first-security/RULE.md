---
name: backend-first-security
description: Applies when writing application code that spans a client and a server — UIs, APIs, webhooks, storage, data access.
---

# Backend-First Security

Zero trust. The client is the view layer only.

- Business logic and data access live on the server, never in client code.
- The client never reaches the database; every data access goes through a server-side handler.
- Credentials and internal APIs are never exposed to the client.
- No public storage buckets: signed URLs and unguessable file names only.
- Verify the signature on every incoming webhook; reject it if verification fails.
- Validate every input at the boundary against a schema; trust nothing from outside.
- Rate-limit every endpoint that changes state.

Before writing code, ask: "Is this asking the client to talk to the database?" If yes, reject it.
