---
name: debugging-discipline
description: Applies when investigating an error, a failure, or behavior that does not match expectations.
---

# Debugging discipline

1. **Read the throw site first.** A precise error from a known library: find that string in its source
   before designing anything.
2. **One command before any diagnostic change.** If a command can tell you, run it instead of adding
   logging. Asking Josh: one command, one fact.
3. **Pushback is signal.** When Josh says something doesn't add up, the claim under it is right even if
   his mechanism is wrong. Re-verify what he challenges. If you are explaining confusion away, the
   confusion is the bug.
4. **Debug switches and warnings change behavior.** Read what a debug or strict mode does before turning
   it on; treat a warning on a normal path as real.
5. **Prove the running version** with a runtime signal (version endpoint, asset hash, a string from the
   latest change). A green pipeline is not live code.
6. **Never remove error handling while debugging.** Add to it.
7. **Cascades have one root.** Many errors sharing one symbol: build, find the structural root, fix only
   that, rebuild.
8. **Third try: stop and re-read the problem.** The answer is usually the simple hypothesis you dismissed.

Done means the build or check reports zero errors.
