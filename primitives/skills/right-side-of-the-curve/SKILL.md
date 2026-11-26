---
name: right-side-of-the-curve
description: Reach the irreducible solution by subtracting machinery from a credible high-capability approach while preserving the outcome and its guarantees. Use for architecture, tool selection, or accumulating models, agents, frameworks, and abstractions. Minimize total operating burden, not just code or visible component count.
---

# Right Side of the Curve

Do not start with "simple is better." Start with what the work must accomplish, including the conditions under which it must still work. Reach the mechanism that remains after unnecessary machinery is removed.

- **Fix the contract.** Identify the outcome, current constraints, and required correctness, safety, recovery, and usability guarantees. Do not delete a requirement to make a solution look smaller.
- **Name the credible default.** Consider the approach a capable practitioner would ordinarily use—not a caricature engineered to lose. Include reuse of what already exists and doing nothing when they can meet the contract.
- **Make each piece pay rent.** For every proposed layer, ask: what exact failure or required capability would appear if this were absent? If there is no concrete answer, remove it from the proposal. If there is, ask whether a smaller mechanism supplies the same guarantee.
- **Count displaced complexity.** A short implementation that transfers work into manual repair, user confusion, hidden configuration, or recurring agent supervision is not necessarily simpler. Compare the complete path through use, change, failure, and recovery.
- **Test the load-bearing boundary.** Use the cheapest safe check that could show a removed piece was necessary. Inspect an actual workflow, exercise a failure case, or prototype the disputed mechanism. Do not claim irreducibility from a confident explanation alone.

Prefer local, deterministic, inspectable, and readily removable mechanisms **when they meet the same contract at lower total burden**. These are tie-breakers, not permission to discard a needed remote dependency, probabilistic capability, or durable guarantee.

For stateful work, test interruption between an external effect and its local acknowledgment or record. A local lock, checksum, or in-memory set does not by itself establish a crash-safe cross-system guarantee. Name the mechanism that actually preserves the contract, or leave that guarantee unverified.

Retain substantial machinery when its removal causes a concrete unmet requirement and no smaller supported alternative addresses it. State that reason plainly; do not add hypothetical future needs to defend the design.

Stop when the remaining pieces have evidenced jobs and further subtraction would break the contract or needs information not currently available. "Smallest supported solution among the examined options" is honest; "globally optimal" usually is not.

Output the surviving mechanism, the decisive reason, and any material boundary that remains unverified. Do not narrate every discarded architecture or build a framework to justify not building one.

**Remove the machinery, not the guarantees.**
