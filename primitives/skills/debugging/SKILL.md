---
name: debugging
description: "Debug faults by choosing the lightest evidence route: direct strike, exact-symptom feedback loop, incident recovery, or evidence-limited handoff. Use for wrong output, crashes, regressions, flaky behavior, performance faults, and urgent production incidents."
---

# Debugging

Start from the symptom or incident you were given.

Get the **smallest safe discriminating fact**. Do not speculate, build diagnostic infrastructure, or change production behavior when authoritative evidence can answer the question directly.

## Choose one route

### 1. Direct strike — authoritative local evidence exists

Use this first when the exact error, failing assertion, compiler output, throw site, local logs, source, configuration, or deployed artifact can settle the question.

1. State the exact symptom and the fact that would discriminate its cause.
2. Read the authoritative source or run the smallest command that returns that fact.
3. Trace from the evidence to the cause. Do not generate alternatives merely to fill a list.
4. Make the smallest supported fix, then rerun the original scenario.

Prefer one command returning one fact over new instrumentation or a multi-command runbook.

### 2. Exact-symptom feedback loop — the fault is unknown and reproducible or measurable

Use this route only when direct evidence does not settle the cause and the exact symptom can be reproduced or measured.

1. Define the exact symptom, the original reproduction or metric, and what counts as changed.
2. Choose the current explanation that best fits the evidence and name the smallest safe experiment that can distinguish it from the alternatives.
3. Predict the result that would support or reject the explanation before running the experiment.
4. Change one relevant variable, observe the exact symptom, and update the explanation from the result.
5. Repeat only while each iteration can produce a new discriminating fact.
6. Apply a production fix only when evidence supports the cause. Rerun the original scenario, not merely a nearby unit test or substitute check.

A minimal reproduction may help, but creating one is not mandatory. The number of explanations is determined by the evidence, not a quota.

### 3. Incident mode — urgent production recovery

Use this route when active impact makes recovery more urgent than diagnosis.

1. Confirm impact and the recovery authority available.
2. Stabilize only through a **known-safe, authorized mitigation** such as an established rollback, failover, traffic stop, or documented feature disable.
3. Do not improvise a novel production change, weaken safeguards, or destroy evidence under incident pressure.
4. Capture only the minimum evidence needed to preserve the symptom and timeline, then verify recovery against the impacted scenario or service signal.
5. After stabilization, move to direct strike or the exact-symptom loop for root cause and permanent repair.

If no known-safe authorized mitigation exists, escalate to the incident owner; urgency does not create authority.

### 4. Evidence-limited mode — unavailable or non-reproducible

Use this route when the system, data, environment, or symptom cannot safely be accessed or reproduced.

1. Separate known facts from reports and assumptions.
2. Name the missing evidence and the smallest safe future observation that would distinguish the leading possibilities.
3. Add narrowly scoped observation only when authorized and only if existing evidence cannot answer the question.
4. Define the trigger, owner, and stopping point for the next observation or escalation.
5. Stop when no new safe discriminating fact is available. Report the limit; do not fill it with a speculative fix.

## Rules for every route

- **No speculative fixes.** Evidence must support the cause before a permanent change.
- **Verify the exact symptom.** A green adjacent check is not proof that the reported fault is gone.
- **Rerun the original scenario.** Preserve its relevant inputs and conditions; use a substitute only when the original is unavailable, and say what remains unverified.
- **Minimize secrets and sensitive data.** Prefer allowlisted fields, identifiers, counts, hashes, and redacted excerpts. Never request or expose credentials, tokens, full payloads, personal data, or unrelated records.
- **Share conclusions and the minimum supporting evidence.** Do not require raw-output disclosure when a redacted fact or local yes/no check is sufficient.
- **Preserve contracts while investigating.** Do not remove existing error handling, safety checks, or access controls to make the symptom disappear.
- **Keep escalation bounded.** Escalate when authority is missing, safety is uncertain, or another iteration cannot produce a new discriminating fact. Name the owner, evidence needed, and current impact.
- **Keep process proportional.** No standing investigation document, commit, fixed hypothesis count, mandatory minimization exercise, or unbounded search is required.
