---
name: debugging-discipline
description: Applies when investigating an error, a failure, or behavior that does not match expectations.
---

# Debugging Discipline

1. **Read the throw site first.** When an error message is precise and comes from a known
   library, find that literal string in the library's source before designing anything. The throw
   site is the answer; the code around it explains the trigger.
2. **One command before any diagnostic change.** Before adding logging or instrumentation, ask
   whether one command could tell you the same thing. If so, run it instead.
3. **One command, one fact.** When asking the operator to run something, hand them one command that
   returns one fact, not a runbook.
4. **Pushback is signal.** When the operator says something doesn't add up, assume the claim under
   it is right even if their mechanism is wrong. Re-verify the assumption they are challenging. If
   you are explaining a confusing observation away, the confusion is the bug.
5. **Debug switches change behavior.** A library's debug, verbose or strict mode may throw where it
   would tolerate, change return values or skip safety checks. Read what it does before turning it
   on.
6. **Warnings are coupling.** Ambient warnings can trigger third-party code that watches for them.
   Treat a warning on a normal path as real until proven otherwise.
7. **Green pipeline is not live code.** Prove the running version with a runtime signal — a version
   endpoint, an asset hash, a unique string from the latest change.
8. **Never remove error handling while debugging.** Add to it; the caller depends on its shape.
9. **Cascades have one root.** When many errors share one symbol or pattern, they are symptoms. Run
   the build or checker first, find the structural root (an unclosed scope, a broken declaration),
   fix only that, and rebuild. One fix, one build, one check.
10. **Three tries means re-read.** On the third diagnostic attempt, stop and re-read the problem.
    The answer is usually the simple hypothesis you dismissed early.

Done means the build or check reports zero errors. "It looks right" is not a passing test.
