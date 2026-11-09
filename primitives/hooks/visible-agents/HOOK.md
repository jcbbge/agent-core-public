---
name: visible-agents
description: Refuses starting an agent the operator cannot see.
---

# Visible Agents

**Event:** before a tool runs.

**Refuses** any way of starting another agent that runs hidden from the operator: in-process,
headless, or in the background, with no session they can open and return to.

**Allows** starting an agent as a session the operator can see.

**The refusal says:** how to start the same agent visibly in this environment.

**Off switch:** none except the worker exception below. A visible way always exists.

Refusal enforcement follows the [worker exception](../../rules/worker-guards/RULE.md).
Workers still start agents visibly.
