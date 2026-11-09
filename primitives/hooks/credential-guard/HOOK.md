---
name: credential-guard
description: Refuses a commit whose added lines contain a secret.
---

# Credential Guard

**Event:** before a commit is recorded.

**Refuses** when an added line in the staged change matches a known credential shape: provider API
keys, cloud access keys, OAuth and chat-platform tokens, private-key blocks, URLs with an inline
password.

**Allows** a commit that only removes a secret, and placeholders.

**The refusal says:** which file and line, which kind of secret, and to move it to an ignored
file or secrets manager.

**When it cannot tell:** the guard's own failure allows, with a warning. It never blocks a commit
because of its own bug.

**Off switch:** an explicit override for one commit, loudly announced.

`scripts/` holds a reference implementation.

Workers follow the [worker exception](../../rules/worker-guards/RULE.md)
before scanning or installation. Worker `--install` is a silent no-op, including
invalid arguments; success does not establish installation. The ordinary explicit
override remains loudly announced.
