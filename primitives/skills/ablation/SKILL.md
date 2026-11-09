---
name: ablation
description: >
  Find where the real value of a role, system, or feature lives by removing its
  functions one at a time and asking not "how bad is the failure" but "what does
  the failure get BLAMED on." Use when a role is treated as an afterthought, when
  a system's value is contested, when prioritizing a backlog whose items all seem
  equally reasonable, or when someone says "I'm not sure what they'd need." The
  diagnostic is misattribution latency, not severity. Produces a two-class split:
  functions that fail loudly as themselves, and functions that fail late wearing
  another department's costume. The second class is where the hidden value is,
  and it is the class no requirements interview will surface.
metadata:
  version: "1.0"
  tags: subtractive-analysis, value-discovery, role-analysis, prioritization, misattribution, hidden-value, ablation-study
---

# Ablation

## What This Is

A subtractive instrument. You do not ask what a role or system *does* — you
remove each function one at a time and watch what breaks, when, and **what gets
blamed for it.**

Additive analysis ("tell me your responsibilities", "what would make your job
easier") reliably returns the visible half of any job. People describe the work
they can see themselves doing. The work that consists of *preventing things* is
invisible even to the person doing it, because its output is an absence.

Ablation finds the absent output by removing the preventer.

## When To Reach For It

- A role is being designed around as an "afterthought" and nobody can say why it
  keeps mattering anyway.
- Someone says **"I'm not sure what they would need"** — the signature of a job
  whose value is in prevention.
- A backlog where every item is individually defensible and no ordering is
  obvious.
- A system whose owners insist it is critical and whose metrics say it is idle.
- Before automating anything a human currently absorbs.
- Succession/bus-factor questions: what leaves when this person leaves.

## The Core Move

Enumerate the functions atomically. For each one, remove it and fill three
columns:

| Remove this | What breaks | **When it's felt** | **What it gets blamed on** |
|---|---|---|---|

The first two columns are ordinary impact analysis and every framework has them.

**The third column is the technique.** It is the whole thing. It asks: at the
moment the damage surfaces, is it *legible as this function's absence*, or does
it arrive wearing someone else's costume?

## Why The Blame Column Is Everything

Severity tells you how much it hurts. Blame tells you **whether anyone will ever
learn.**

A failure that is diagnosable as itself gets fixed. It generates its own
feedback: the thing broke, the cause is obvious, someone restores the function.
These failures are self-healing at the organizational level and they need no
advocate.

A failure that surfaces as something else **generates no learning at all.** It is
attributed to the department where the symptom lands, absorbed as that
department's cost, and the actual missing function is never named — so it is
never restored, never resourced, and never appears in any requirements document.
Worse: fixing the symptom repeatedly *looks like competent management.*

Misattribution, not severity, is what makes value invisible. So misattribution is
what you measure.

## The Two Classes

Sort every row by the third column.

**Class A — fails loudly, as itself.** Fast, visible, unambiguous cause. If the
function vanished it would be noticed within hours or days and backfilled
quickly. These are the functions leadership can see. **They are what tools get
built for**, because they are the ones anybody can describe.

**Class B — fails late, as something else.** Slow, and the symptom lands in
another team's ledger. Nobody diagnoses it. A competent successor would not know
Class B existed, would perform Class A well, and the organization would bleed
through Class B for months while attributing each symptom to a different cause.

**Class B is where the value is, and Class B is what the interview will not
give you.**

## Procedure

1. **Enumerate atomically.** Split until each item can be removed independently.
   "Manages inventory" is not a function; "maintains par levels", "replaces worn
   items", "sources under shortage" are three functions with three different
   failure signatures. Over-splitting is cheap; under-splitting hides the finding.

2. **Remove one. Hold everything else constant.** Resist compensating — do not
   let an imagined heroic colleague absorb it.

3. **Fill the three columns.** Be concrete about time-to-felt. Hours / days /
   weeks / months is enough resolution; the class boundary usually falls between
   "days" and "weeks."

4. **Label inference.** Time-to-felt and blame-target are usually reasoned, not
   observed. Mark them as such. An ablation table full of unlabeled guesses is a
   fiction with a grid around it.

5. **Sort by column three.** Class A and Class B separate themselves. If
   everything lands in Class A, you have not split finely enough, or the role
   genuinely is what it appears to be — both are useful answers.

6. **Read the Class B list as the real requirements document.** Each Class B row
   is a function that needs to *leave a trace* — not be automated. The ask is
   almost never "do this for me"; it is "let the fact that I did this be
   visible."

7. **Follow the laundering chain.** For each Class B row, trace the symptom to
   where the cost actually lands. Those chains close loops, and a closed loop
   names the mechanism, which is what makes the finding actionable rather than
   merely interesting.

## What It Produces

- A prioritization that is not severity-ordered and usually contradicts the
  intuitive one.
- The reason a role reads as an afterthought: **a well-absorbed variance leaves
  no trace in the data**, so the better someone is at a Class B function, the
  more invisible the function becomes. This is a measurement artifact, not
  neglect — say so, because it changes who you are arguing with.
- A bus-factor map: Class B is precisely what does not survive a departure.
- Frequently: an item already sitting in the backlog as a "nice to have,"
  revealed as the keystone. Class B work gets filed as derived-insight garnish
  because its value was never legible.

## Failure Modes Of This Technique

| Failure | Signature | Correction |
|---|---|---|
| **Ablating a noun** | rows like "remove inventory" | ablate *functions*, not objects |
| **Compensating removal** | "well, someone else would catch it" | hold everything else constant |
| **Severity capture** | table sorted by how bad it is | sort by blame, always |
| **Fictional precision** | confident timings, no provenance | label inference as inference |
| **Automation reflex** | Class B row → "automate it" | Class B usually wants *recording*, not automation. The judgment is the value; the invisibility is the problem |
| **Ablating to justify** | you already know the conclusion | run it on functions you expect to be worthless; if nothing surprises you, you are confirming, not ablating |

## What This Is Not

- **Not FMEA.** Failure-mode-and-effects analysis scores severity × occurrence ×
  detectability on *components failing*. Ablation removes *functions working* and
  scores attribution. FMEA asks "what if this breaks"; ablation asks "who gets
  blamed when this is absent." Related family, different diagnostic.
- **Not an ML ablation study**, though the name is borrowed honestly: same move
  (remove a component, measure the delta), different metric — organizational
  attribution rather than task performance.
- **Not a criticism of anyone.** The output frequently explains why a competent
  manager rationally under-resourced something. Present it as a measurement
  problem, because that is what it is.

## Worked Example (an events and hospitality production role)

Subject: a production manager at an events company, treated as downstream of
sales in the product design, whose contribution nobody could articulate.

Additive interviewing produced her documents — the lists she makes. Ablation
produced the finding:

| Removed | Breaks | Felt | Blamed on |
|---|---|---|---|
| per-event pack list | wrong equipment on site | hours | itself |
| sourcing under shortage | the event fails | hours | itself |
| consumables restock | venue runs dry mid-event | hours | venue staff |
| overnight turnover sheet | crew does the wrong thing | ~24h | the crew |
| lot discipline (owned vs rented) | cannot return the right units | weeks | a vendor billing dispute |
| forward lookahead | shortage found too late | 2–4 weeks | the sourcing budget |
| attrition / replacement tracking | promising stock that no longer exists | months | a stockout, or "bad counts" |

Class A: the first four. Class B: the last three.

The laundering chain that fell out of step 7: no replacement schedule → reactive
replacement → shortfall discovered at point of use → no lead time → scramble →
resolved as a vendor rental or a client credit → **cost recorded, cause erased.**
The organization was paying for the absence of one function through two other
budgets, indefinitely, with no mechanism that could ever connect them.

That chain was invisible to every additive question asked over two interviews. It
took eleven subtractions and one blame column.
