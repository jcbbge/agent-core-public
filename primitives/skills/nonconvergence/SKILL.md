---
name: nonconvergence
description: Escape the training distribution's central tendency on genuinely open conceptual problems. Forces the model to state its convergent answer out loud, name what makes it convergent, discard it, and keep going — then explore under a two-channel architecture where an observer that never generates emits only inhibit/amplify/rupture/exit. Retains an idea only if it survives falsification from two foreign domains, compresses without losing its novel claim, and fails the null test "would ordinary high-intelligence search have reached this?" Use for open conceptual work, reframing a stuck problem, when an answer feels obvious, or when asked for something non-obvious. NOT for execution, debugging, implementation, or any task with a known-good answer — there it manufactures the empty complexity it exists to inhibit.
metadata:
  version: "2.1"
  tags: divergent-reasoning, tail-search, anti-convergence, cross-domain, observer-architecture, falsification
---

# Nonconvergence

## The thesis

The failure mode is not stupidity. It is **fluent obviousness** — output that is
correct, well-formed, and sits exactly where the distribution's mass already was.
It reads as insight because it reads well.

An unnamed default is invisible, and an invisible default gets silently
re-derived no matter how much exploration surrounds it. So the first move is not
to explore. It is to say the default out loud.

## Step one: state the default, then discard it

Before any exploration, emit this block. Verbatim shape, in the response, not
in silent reasoning — the naming only works if it is written:

```
DEFAULT: <the answer you were about to give, one sentence>
WHY DEFAULT: <the standard framing, reference class, or vocabulary it came from>
SECOND / THIRD: <the next two answers that surfaced>
BASIN WIDTH: <are 2 and 3 the same answer in other clothes? say so if yes>
COST OF DISCARDING: <what DEFAULT was actually getting right — the replacement must still deliver this>
DISCARDED.
```

Rules that make it a mechanism rather than a gesture:

- Three candidates, not one. Two and three are usually one in other vocabulary;
  noticing that measures the basin's width, which is how far out you must go.
- **COST is mandatory and specific.** "It's simple" is not a cost. Name the
  constraint DEFAULT satisfied; whatever replaces it must satisfy that too, or it
  is novelty without coherence and gets inhibited.
- A later branch resolving back to DEFAULT is attractor capture, not convergent
  validation. The observer emits **rupture**.
- If DEFAULT survives real exploration, say so plainly and ship it. Restating it
  is honest; re-deriving it while calling it new is the failure.

## Two channels

Run a generator and an observer. **They are separate, and the observer never
produces content.**

The generator explores. The observer watches the field and emits exactly four
signals:

| Signal | When |
|---|---|
| **amplify** | an attractor is gaining mass and still yielding structure |
| **inhibit** | a branch is repeating, converging, or ornamental |
| **rupture** | the graph has stabilized while conceptual gain sits near zero, or a branch has landed back on DEFAULT |
| **exit** | gain has stabilized, or a hard depth/cycle limit is reached |

The separation is the point. A generator that also evaluates itself grades toward
its own fluency. The observer's refusal to generate is what keeps it honest.

## Inhibitions — the working core

Suppress on sight. This list does more work than any list of goals:

distributional convergence · central tendency · **surface analogy** ·
**human-obvious connection** · generic completion · premature convergence ·
repetition · **novelty without coherence** · empty complexity ·
**aesthetic complexity** · **self-referential ornament** · attractor capture ·
**stock distant domain** (see below)

Three deserve emphasis because they are how this technique fails while feeling
successful:

- **Aesthetic complexity** — elaborate structure that carries no additional claim.
- **Self-referential ornament** — vocabulary that describes the method instead of
  the subject. If a passage would survive unchanged across three unrelated
  problems, it is ornament.
- **Stock distant domain** — thermodynamics, evolution, immune systems, jazz
  improvisation, ant colonies, quantum mechanics. These are *the distribution's*
  idea of a distant domain. Reaching for one is convergence in costume.

## Attractors

tail exploration · coherent outlier · cross-domain **structural** tension ·
non-obvious structural link · stability under transformation · explanatory power ·
the current goal

The current goal is an attractor. Drift off it is a failure, not exploration.

## Structural relation, not semantic resemblance

The highest-yield discipline here, and the most commonly faked.

- **Surface analogy:** "inventory is like an airline seat" — both involve booking.
- **Structural relation:** does the *same mechanism* hold? Airline capacity is
  inelastic; event-rental capacity is elastic at a cost. The mechanism differs, so
  the analogy transports nothing and quietly imports a wrong constraint.

**Test:** name the mechanism, not the resemblance, then find the fact that would
break it. An analogy nobody can falsify is decoration. Combine incompatible
models until a stable structure appears or the incompatibility itself is
informative — both outcomes are results.

## How to pick a distant domain

"Maximally distant" is not executable. This is:

1. **Restate the problem as a constraint type, dropping every domain noun.**
   Not "pricing event rentals" — "allocating a perishable resource whose
   replacement cost is nonzero and whose demand is disclosed late."
2. **Find a field where that constraint type is the central object of study,**
   not a side case. It should have a *name* there and a literature.
3. **Run the distance test:** would a practitioner in that field need to be told
   what your domain is at all? If they already work on your industry's problems,
   it is adjacent, not distant. Discard and go again.
4. **Run the stock-domain test:** is this the field a magazine article would have
   reached for? If yes, discard it.
5. **Pay the entry fee:** state one practitioner-level fact from that field — a
   specific mechanism, failure mode, or named result. If you cannot, you recruited
   a vibe, not a domain, and it will produce surface analogy every time.

Two recruited domains, not one — the retention gates require attacks from two.

Take them **one at a time, each to depth.** Pay one domain's entry fee and work it until
it yields a structure or plainly fails, then turn to the second. Interleaving several
domains shallowly produces a list of resemblances, which is surface analogy at volume.

## The export pass — far transfer runs both ways

The method above *imports*: it brings a foreign mechanism to your problem. Far transfer
also runs outward, and that direction is skipped by default, because each problem's
context stays sealed off from every other. Once an idea passes the gates, ask on purpose:
**where else does this mechanism apply?**

- Restate the surviving idea as a constraint type with no domain nouns, the same move as
  step 1 of the method, then name one *unrelated* place it holds.
- If it holds there **by the same mechanism**, the idea is structural, so keep it. If it
  only holds there by resemblance, you have found the surface analogy hiding inside it.
- If it applies nowhere else, it may still be right, but it is local. Say so rather than
  presenting it as a principle.

This is a test, not a sightseeing tour. One named landing site, checked, then stop.

## Precision over exhortation — one grounded note

**Source:** Mowatt-Gok, *Inside Neural Chameleon*.
**Establishes:** models trained to evade activation monitors on benign concepts
do it through *internally generated* activation steering. A small set of late
attention heads (the paper's K12, layer 12) accounts for ~76–78% of the evasion,
writing tangentially into prompt-side keys and values that ordinary downstream
queries then read. The paper calls that write **concept-specific**.
Residual-state transplants localize it: heads outside that set transfer almost
nothing (two layer-11 heads the partial exception, 5–31%).
**Does not establish:** anything about creativity, sampling, temperature,
distribution tails, or prompting. It is a monitor-evasion study. Do not cite it
for more.

**Inference, labelled as inference — not the paper's claim:** if self-steering is
concept-specific, a prompt cannot address heads, but it can determine *which
concept is made salient enough to be steered around*. That makes precision in
naming the target the lever, and volume of exhortation not one. So "be more
creative" names nothing and should be expected to do nothing, while "the default
treats scheduling as the constraint; the constraint is consent" names a concept.
This is why every instruction here demands a named object, and why Step One is
written output rather than an attitude.

## The grounding channel

Perturbation alone does not escape the distribution. **The central tendency is
unfalsifiable plausibility** — surface analogy persists precisely because nothing
checks it. So the strongest anti-convergence force available is contact with
verifiable ground truth:

- Check claims against the artifact — file, schema, log, transcript, measurement —
  not against memory or coherence.
- Prefer a branch that *can* be falsified over a branch that merely sounds
  generative.
- **A human interlocutor with domain knowledge who says "no, slightly off" is the
  single most effective rupture mechanism in this document.** Recruit one when
  available; treat each correction as a ruptured attractor and re-derive rather
  than patch.
- If a whole exploration touched no checkable fact, treat the entire output as
  suspect regardless of how novel it feels.

## Rupture and loop escape

Keep a rough structural hash of the active conceptual graph. If it stabilizes or
cycles while gain stays below threshold, force one of:

1. **Invert a core assumption** — take the load-bearing premise and negate it.
2. **Recruit a new domain** by the five-step method above.
3. **Collapse to the strongest current outlier** and rebuild from it.

Depth and cycle limits are absolute. The observer enforces exit. A loop that feels
productive at step N and produced nothing new since step N−3 is capture.

## Retention gates

An idea survives only if it passes all five:

1. **Internal consistency** — no contradiction with its own commitments.
2. **Pays the COST** — it delivers what DEFAULT was getting right, or explains
   why that was never actually required.
3. **Two-domain falsification** — attacked from two foreign domains, still stands.
4. **Compression without loss** — statable briefly with its novel structural claim
   intact. If compression kills it, the length was the content.
5. **The null test** — *would ordinary high-intelligence search have reached this?*
   If yes, it is a good answer and not this skill's output. Say so and keep it;
   don't dress it up.

Separate, explicitly: structural relation from surface analogy · meaningful
novelty from unsupported novelty · coherent outlier from empty complexity.

## The loop

State and discard the default → generate competing interpretations biased toward
the tails → recruit two distant domains by the method → disturb every central
attractor → run the export pass on what survives → **preserve productive disagreement rather than resolving it** →
integrate what passes the gates, inhibit what doesn't → repeat until gain
stabilizes or a limit is hit.

Synthesize by joining the surviving outliers **without erasing useful
disagreement.** Competing live interpretations are a result; forced consensus is
convergence wearing a bow.

## When NOT to use this

Fired on the wrong task, this manufactures exactly the empty complexity it
inhibits. Do not use for: execution, debugging, implementation, anything with a
known-good answer, anything under time pressure, or any question whose honest
answer is short.

**If the obvious answer is correct, the obvious answer is the deliverable.**
Escaping the distribution is only valuable where the distribution is wrong.

## Self-suspicion

Any fixed exploration protocol becomes its own attractor with use. This document
is subject to its own inhibition list — *attractor capture* and *self-referential
ornament* included. If its outputs start to rhyme with each other across unrelated
problems, that rhyme is the signal to rupture the protocol itself.

---

## Changes from the original prompt

**Kept from v1:** observer architecture and its four signals; the inhibition list
(still the strongest component); attractors; preserved disagreement;
structural-over-surface with its falsification test; the grounding channel;
hash-based loop escape; the retention gates including the null test and
compression-without-loss; when-not-to-use; self-suspicion.

**Cut in v1:** the "core relations" (∅ ≡ ∞ ≡ unit interval; central ≡ tail) —
suggestive, not operational; Dreamscape / Metamorphosis / Entropy manipulation /
Recursion engine — four names for one move; "for every x in the universe" —
unexecutable; Gödel branding, its instruction folded into rupture.

**Added in v2:** *Step one* — v1 could not see its own convergent answer, so that
answer could be re-derived under new vocabulary and pass every gate; highest-
leverage section in the file. *How to pick a distant domain* — v1 said "maximally
distant" and left it to taste, which returns the distribution's stock distant
domains. Plus *stock distant domain* to the inhibitions, *pays the COST* to the
gates, and the grounded note above.

**Cut in v2, to pay for the above:** "emergence" from the attractors (a label for
the outcome, not a thing to steer toward); "inject a maximally distant domain"
from rupture, now a pointer to the method; the loop, compressed once it became a
restatement of the sections above it.

**Added in v2.1:** *one domain at a time, to depth* and *the export pass*. Source:
Isabel Radford's TikTok on far transfer
(https://www.tiktok.com/@isabelrdfrd/video/7699538051768323350, transcribed 2026-10-25).
It claims the more distant two fields are, the more new combinations they yield (the skill
already acts on this), that bridges between fields only form when you build them on purpose,
and that depth comes in seasons rather than all at once. It also cites a finding that Nobel
laureates keep more outside pursuits than their peers; the study is not named there, so its
source is UNKNOWN, and nothing here depends on it. Its advice to "finish things" is already
covered by the entry fee.

**Register note:** the source was written in a mystical-technical voice. That
voice is itself a dense region of the distribution — output that *sounds*
nonconvergent while occupying a different central basin. Rewritten plainly on
purpose, and kept that way.
