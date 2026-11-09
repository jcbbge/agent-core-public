---
name: long-running-processes
description: Applies when starting anything that keeps running — a dev server, a watcher, a log stream, a background job.
---

# Long-Running Processes

**If you start it, you own its teardown.** No session ends with a process you started still
running, unless the operator asked for it to stay.

1. **Prefer one-shot.** Type-check, build, test and read logs with forms that run once and exit.
   Watch modes and dev servers are for a human's interactive loop; verifying a change almost never
   needs one.
2. **If it must run, keep it attached.** Start it through whatever the environment tracks and
   reaps with the session. Never detach it from the session, or it outlives you and runs forever.
   Stop the whole process group, not just the parent.
3. **Pick the watching mode by why you are watching:**
   - Need recent history → read a window of it and exit.
   - Need to act on a specific condition this turn → watch with a hard time limit, and stop the
     moment the condition appears.
   - Open-ended watching for the operator's eyes → don't run it. Give them the command to run in
     their own terminal.
4. **Before ending,** check that everything you started is gone.
5. **If the operator wants it to stay,** say so plainly: what is running, where, and how to stop
   it. Persistence is a stated decision, never an accident.
