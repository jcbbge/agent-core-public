---
name: secrets
description: Applies when you need, hold, write or stage a credential, or edit config, environment files, service definitions or CI files that could hold one.
---

# Secrets

A secret is an API key, token, password, signing key, or any credential that rotates or costs money.

## Never in a file that is or could be committed

- Load secrets at runtime from an ignored file or a secrets manager; service and job definitions too.
  Committed templates hold placeholders only. Non-secret config (local URLs, names, sizes) may be inline.
- Before staging config, inspect every value. A real key goes to the ignored file first, and the
  example file lists the expected keys.
- A repo with service definitions or environment files runs a secret scanner on commit (the
  [worker exception](../worker-guards/RULE.md) skips the scan, never the rule). A hit is removed from
  history before it is pushed, never bypassed.
- Never print, log or commit a secret, or put one in argv, environment, chat, briefs or memory. Pass it
  only through the command's file or stdin interface.

## Credentials Josh authorized you to keep

- Retained credentials live in protected runtime storage (directory 0700, file 0600, owned by Josh);
  agent-core and memory hold only where they are, never their values. The machine's entrypoint names
  the location (on hive: `~/AGENTS.md`).
- Before asking for a credential, check that location: ownership, permissions, account, expiry, without
  printing the value. A valid one is used for already-authorized work. A new thread is not a reason to
  ask again.
- Never delete a retained credential at task or session end; only on revocation, rotation or his word.
  Never overwrite one blindly or keep an expiring token alive by copying it.
- No usable credential left: report that and finish the independent work. Don't prompt repeatedly;
  after he says stop asking, wait for him to start the replacement.
- A saved password authenticates; it does not authorize unrelated privileged actions.
- Never claim a credential was saved when only instructions or an empty directory were.

## A disposable test key Josh hands you

When he supplies a disposable key and authorizes a test with it, use exactly that key for that test,
ahead of any saved one. Read it into process memory from his message in this conversation (or one he
names), never search other histories, and never save it anywhere unless he authorizes retention. Pass it
by stdin or another protected source, never in a tool call's literal text. Use it against the requested
URL and interface, report the real status with the secret redacted, and stop using it when the test ends.
If that path is unavailable, say exactly why; never substitute another key or claim the test ran.
