---
name: report-contract
description: Applies whenever you stop and report — to the operator or to whoever gave you the work.
---

# Report Contract

A report is not a log. A log says what happened; a report says what is now true, what is unproven,
and what only the reader can decide.

## Leave out

Narrative paragraphs; micro-operations (files touched, commits made, branches deleted) unless one
is the subject of a decision; routine successes; status theatre; any unproven claim stated as fact.

## The five sections

Write `None.` under a section that is empty; never drop the heading. An absent section cannot be
told apart from one nobody checked.

1. **Intent and state.** What the work was for, in a sentence a reader who was away can follow.
   Its state: active, blocked, reported, or accepted (accepted only when someone other than the
   doer checked it). The delta: what changed in the world, as capabilities reached, not files
   edited. If not done: the one root blocker, and who owns it.
2. **What is unproven.** Split the delta in two. Measured — and by what, run this session.
   Unproven — and what would prove it and why you could not. "Wired" is not "works";
   "committed" is not "landed"; "it should" is not a measurement.
   Name the `teerex records` id that holds the checks, omissions and cleanup behind this section when one exists.
3. **Decisions owed.** Only those that block the work or need the operator's judgment on
   direction, risk or cost. Settle anything looking could settle and report the ruling in the
   delta instead. For each real decision: the issue, why now, the options with what each gains and
   loses, and your recommendation with its reason. Always recommend.
   A decision you settled goes in the delta with its `teerex records` id. A decision you need goes here.
4. **Next.** What runs the moment the decisions land, and what proceeds regardless. If you are
   blocked and nothing proceeds regardless, you stopped early.
5. **Still running.** Everything you started that still uses resources: what it is, whether it is
   meant to survive, and who stops it.

Length: what the content demands and not one line more.
