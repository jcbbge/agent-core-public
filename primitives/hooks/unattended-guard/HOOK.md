---
name: unattended-guard
description: Refuses installing anything that runs on its own — scheduled jobs, timers, always-on services — without the operator's yes.
---

# Unattended Guard

**Event:** before a shell command runs, and before a file is written.

**Refuses** installing or enabling anything that runs without a session: a scheduled job, a timer,
a user or system service, an entry in the machine's scheduler — by command or by writing its
definition file.

**Allows** reading or listing what is scheduled, and anything after the operator said yes this
session.

**Judges code, not text** (see `shared-checkout-guard`).

**The refusal says:** what would have run, and to ask the operator as a decision — what runs,
when, what it can change, how to turn it off.

**Off switch:** an explicit per-command override, used only after the operator's yes.

Refusal enforcement follows the [worker exception](../../rules/worker-guards/RULE.md).
Workers still need the operator's yes before unattended installation.
