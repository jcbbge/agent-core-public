---
name: secrets
description: Applies when writing, editing or staging config, environment files, service definitions, CI files, or anything that could hold a credential.
---

# Secrets

A secret — an API key, token, password, signing key, or any credential that rotates or costs
money — is never written into a file that is or could be committed.

- Load secrets at runtime from an ignored file or a secrets manager. Service and job definitions
  get them the same way, never inline.
- Committed templates hold placeholders only.
- Non-secret config (local URLs, defaults, names, sizes) may be inline.
- Before staging any config, inspect every value. Anything that looks like a real key or token
  goes out to the ignored file first; then update the example file that lists the expected keys.
- A repo that holds service definitions or environment files has a secret scanner active on
  commit, subject to the [worker exception](../worker-guards/RULE.md).
  The exception skips mechanical scanning; it does not permit committing secrets.
- A scanner hit is removed from history before it is pushed, never bypassed.
