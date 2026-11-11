---
name: rex-context
description: At session start, tells the agent where the live Rex API description and docs are.
---

**Event:** session-start.

**Adds:** live API cache and lookup context; it refuses nothing.

**When it cannot tell:** prints nothing and exits 0.

**Off switch:** remove the hook entry.

`scripts/` holds a reference implementation.
