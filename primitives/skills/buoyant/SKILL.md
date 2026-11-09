---
name: buoyant
description: Hygiene for model-shaped weight. Mark what the next model will lift, and what to delete when it does. Use as /buoyant, on "is it buoyant?", after an implement pass, or when the repo feels bloated (docs, notes, plans, internals, source).
---

Buoyant work gets better when the model does. You don't lift it. Hygiene is taking weight off the boat.

Two piles:
- **Tide** — the next model improves this. Leave it.
- **Compensation** — this exists because today's model is weak, or because last sitting's sandbags are still aboard. Write when it comes off.

The audit is the delete list. No essay.

## Cut — implementor

Scope: this sitting's diff. The agent who wrote the code runs this before they call it done.

Look at what you added: extra files, helper layers, "robust" branches, comments that exist to steer a weak model, docs that restated the code, plans that survived the cut.

Output:
1. **Delete now**
2. **Comes off when** (named capability, not a date)
3. **Tide** (leave)

## Corpus — the repo

Scope: the tree, not the sitting. Walk docs, notes, plans, internal-facing glue, then source. Fight entropy: bloated modules, refactors stranded across files, systems that were a crutch and calcified into architecture.

Same two piles. Same delete list. Name files. Don't start a rewrite. Take one weight off now, then stop.

If you cannot name a file, you are not done looking. `UNKNOWN` is allowed. A vibe is not.
