---
name: credential-continuity
description: Applies before requesting, using, retaining or deleting an operator credential, including sudo authentication across sessions.
---

# Credential continuity

The operator explicitly wants credentials reused across threads and sessions.
Keep the credential in protected runtime storage; agent-core and memory carry
only its location and handling instructions, never its value.

- Before prompting, check the machine's credential pointer and protected delivery
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
  were saved. Do not recover credentials from conversation records or logs.

The local machine entrypoint owns its concrete runtime location. This rule does
not introduce a credential service or change installed guards.
