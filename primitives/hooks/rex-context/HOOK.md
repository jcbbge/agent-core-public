---
name: rex-context
description: At session start, tells the agent where the installed Rex and teerex command guides are.
---

**Event:** session-start.

**Adds:** pointers to the installed Rex and teerex guides, named hosts and pane commands; it refuses nothing. It creates no cache and starts no background process.

**When it cannot tell:** prints nothing and exits 0.

**Off switch:** remove the hook entry.

`scripts/` holds a reference implementation.
