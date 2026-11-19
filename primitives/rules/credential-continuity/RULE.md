---
name: credential-continuity
description: Applies before requesting, using, retaining or deleting an operator credential, including sudo authentication across sessions.
---

# Credential continuity

The operator wants credentials authorized for retention reused across threads and
sessions. Keep retained credentials in protected runtime storage; agent-core and
memory carry only their location and handling instructions, never their values.
Disposable test credentials follow the explicit exception below.

- Outside the disposable-test exception below, before prompting, check the machine's
  credential pointer and protected delivery
  metadata. Inspect ownership, permissions, intended account and any expiry without
  printing the value. Use an existing valid credential for already-authorized work.
- When the operator has authorized retention, preserve a delivered password in the
  machine's private runtime location (directory mode 0700, regular file mode 0600,
  owned by the operator). Do not overwrite another credential blindly. Do not keep
  an expiring token alive by copying it or treat a one-use secret reference as reusable.
- Pass password bytes only through the command's supported protected file or stdin
  interface. Never put them in chat, argv, environment, logs, Git, briefs or memory.
- Do not delete a retained credential at task completion, session end, or runtime
  stop. Remove or replace it only on revocation, rotation, or explicit instruction.
- Authentication and permission to perform an action are separate. A saved password
  does not grant authority for unrelated privileged actions or sudoers changes.
- If no usable credential remains, report that fact and finish independent work.
  Do not repeatedly prompt. After an explicit instruction to stop password prompts,
  wait for the operator to initiate credential replacement.
- Never claim a password was saved when only instructions or an empty directory
  were saved. Do not recover credentials from conversation records or logs except
  under the narrowly authorized disposable-test exception below.

## Explicitly authorized disposable-key tests

When the operator supplies a disposable API key and explicitly authorizes a test
with that key, use that exact key for that test. This exception takes precedence
over the retained-credential lookup and conversation-recovery prohibitions above.

- The key may be read into process memory from its operator-authored message in
  the current conversation, or from a specific conversation the operator explicitly
  identifies as the source for this test. Read only the credential needed for the
  authorized test; do not search unrelated histories or logs for credentials.
- Do not save it to a credential file, environment, configuration, memory store or
  other durable location unless the operator separately authorizes retention. Do
  not replace or use an existing saved key as a substitute.
- Extract the value at runtime without returning it in tool output. Pass it to the
  HTTP client through protected stdin or an already-authorized protected source.
  A tool call may contain extraction code and the source location, but never the
  literal key. Do not echo it or include it in argv, logs, Git, briefs or replies.
- Perform the requested request against the requested URL and interface. API-key
  HTTP tests use the supplied bearer key, not MCP or ambient browser cookies.
  Report the actual status and relevant result, with secret values redacted.
- Do not require the operator to re-enter the key or run a command merely because
  it was supplied in chat when the permitted runtime extraction is available.
  If that mechanism is unavailable, report the specific technical limitation;
  never silently substitute another credential or claim the test ran.
- This exception permits use, not disclosure, retention, unrelated access or
  unrequested rotation. The general prohibition on printing or logging secrets
  still applies. End use when the test ends.

The local machine entrypoint owns its concrete runtime location. This rule does
not introduce a credential service or change installed guards.
