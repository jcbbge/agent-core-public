# Standard: receiving webhooks

### 1. Verify before anything else
- Verify the sender's signature (usually an HMAC-SHA256) over the **raw** request body, before parsing it, using a constant-time comparison. Reject when verification fails.
- Reject a request whose signed timestamp is outside a small window (about 5 minutes).
- The signing secret is per sender and loaded at runtime. Rotation supports two valid secrets at once while switching over.
  *Measure:* an unsigned request, a wrongly signed one, a body altered after signing and a stale timestamp each get 401 with no side effect.

### 2. Idempotency
- Record each event ID. A repeated delivery returns 2xx and does nothing.
  *Measure:* sending the same signed event twice produces one effect.

### 3. Acknowledge fast, process separately
- Verify, record the event and return 2xx immediately. Do the work from a queue or job, with retries and a dead-letter store.
  *Measure:* the handler responds within the sender's timeout even when processing is slow.

### 4. Trust only what you check
- The payload is untrusted input: validate it against a schema. For important actions, fetch the current state back from the sender's API rather than trusting the payload's claims.
  *Measure:* a validly signed but malformed payload fails safely and goes to the dead-letter store.

### 5. Bounds and switches
- Body-size cap, a rate limit per sender, a switch per sender, and an event for each verification failure.
  *Measure:* turning off one sender's switch stops processing for that sender only.
