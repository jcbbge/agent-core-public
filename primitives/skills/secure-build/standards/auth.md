# Standard: sign-in, sessions and tokens

Covers OpenID Connect sign-in (Google or any provider), browser sessions, and tokens issued to
agents or other services.

### 1. Identity comes from a verified token
- Use the Authorization Code flow with PKCE (`S256`), plus `state` and `nonce`.
- Verify the ID token's signature against the provider's published keys, and check `iss`, `aud` (your client ID), `exp` and `nonce`.
- Admission requires the provider's *verified* claims (email verified, organisation or domain claim) **and** an active user in your own user table. Your user table decides access; the provider only proves who the person is.
  *Measure:* a non-organisation account, a disabled user and a token signed for another client are each refused.

### 2. Browser sessions
- Sessions are server-side and revocable. The cookie is `__Host-`, `Secure`, `HttpOnly` and `SameSite=Lax` (or `Strict`).
- The session ID rotates at sign-in. Sessions have an idle timeout and an absolute timeout. Sign-out destroys the session on the server.
  *Measure:* the old session ID is dead after sign-in; a session dies at its absolute timeout; after sign-out, the old cookie gets 401.

### 3. Tokens you issue (agents, services, MCP)
- Your app issues its own tokens. **Never accept or forward the identity provider's token as your API credential.**
- Each token has an audience (the one resource it is for), a narrow scope and a short life. Refresh tokens rotate, and reusing one revokes the whole token family.
- Tokens are stored as hashes and are revocable individually and all at once. They never appear in URLs or logs.
- Different credential types don't substitute for each other: a browser session doesn't work on agent endpoints, and an agent token doesn't work on browser routes.
  *Measure:* the wrong audience gets 401; a reused refresh token revokes the family; each credential type is rejected on the other's routes.

### 4. Authorization model
- Roles and permissions are defined in one place and checked on the server. Admin is a separate role, granted to few, and audited.
  *Measure:* the list of principals and roles matches the written intent; no unexplained admins.

### 5. Brute force and account takeover
- Sign-in and token endpoints are rate-limited per IP and per account. Failure-then-success bursts and new-location sign-ins are logged as events.
  *Measure:* a burst of failed sign-ins is throttled, and appears in the live view.

### 6. Accounts that can do damage
- Accounts that can deploy, pay, change DNS or read production use phishing-resistant MFA (passkey or hardware key).
  *Measure:* the list of those accounts shows MFA type for each.
