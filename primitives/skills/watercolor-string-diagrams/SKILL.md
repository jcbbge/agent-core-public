---
name: watercolor-string-diagrams
description: Decompose a process, workflow, state machine, ritual, concurrent system, or software ecosystem into typed string diagrams and render a complete interactive p5.js sketch with p5.brush watercolor washes and ink wires. Use for watercolor/ink process maps or an explicit String Diagram Architect request; preserve the actual system rather than imposing ordinary flowchart semantics.
---

# String Diagram Architect & Watercolor/Ink Renderer

Turn a process description into two artifacts, in this order:

1. **String Diagram Specification** — Markdown containing the signature, composition, explicit layout, categorical notes and color map.
2. **Complete p5.js Sketch** — runnable HTML with the full JavaScript, loading p5 and p5.brush. Link both files and show the visual using the host's supported display mechanism when available.

Accept ordinary prose or text after `PROCESS:`. If applying this to an existing installation, inspect its entrypoint, source, installed packages and runtime before drawing it. Keep observed operation, installed capability, historical fixture, proposal and unknown distinct. Record sources with the relevant claim. A registered type is not a running instance; an Actor's residency is not an agent's job status.

## Decompose before painting

Extract a signature of precisely named objects and atomic morphisms:

- **Objects / wires:** resources, states, data types, materials, attention, energy or time slices. Give each a stable ID and meaning. Name state versions when something mutates.
- **Morphisms / boxes:** the smallest useful transformations, actions, decisions or events. Use a verb label, stable ID and an ordered typed input/output list: `f : A ⊗ B → C ⊗ D`.
- **Sequential composition:** `f ; g`, only when the output boundary of `f` matches the input boundary of `g`.
- **Parallel composition:** `f ⊗ g` (or `++`). Parallel placement means independence at the displayed abstraction, not an unverified runtime concurrency guarantee.
- **Symmetry:** explicit swaps/braids reorder resources without transforming them. Crossing wires do not join.
- **Units, copy, discard:** expose the relevant generators and label their types. A generic monoidal category has no automatic copy or discard. Copy immutable descriptions only under an explicitly stated structure; never duplicate an exclusive resource or credential by drawing a fork.
- **Decisions:** model a tagged sum and guarded alternatives when needed. A choice is not a tensor that executes every branch.
- **State / feedback:** preserve state on input and output, e.g. `commit : Operation ⊗ Database → Receipt ⊗ Database`. Use a delay/stateful trace for temporal feedback. Do not invent compact duals, cups/caps, time travel or fixed-point guarantees to justify a back edge. Cups/caps require a stated duality with a domain interpretation.

Start with the free symmetric monoidal category on the signature. State any additional structure actually needed: finite sums for alternatives, selected copyable data, or delayed traces for state. Do not claim operational equations such as commutativity, idempotence or exactly-once effects without evidence. Distinguish a structural drawing equation from a measured software property.

Look for hidden parallel resources (authority, retained state, runtime ownership, attention, artifact bytes). Prefer a useful non-obvious decomposition that remains faithful to the input. When alternatives matter, name them briefly. For a phase of a day, carry time alongside attention/energy/materials; actual events transform these wires.

## Specification contract

Include:

1. **Scope and evidence:** the process, observation time if applicable, abstraction boundary and uncertainties.
2. **Signature:** objects plus each morphism's ordered types. Distinguish a product/package from the operation it supplies.
3. **Composition:** type-correct expressions with `;` and `⊗`, boundary inputs/outputs, identities and swaps where necessary. A list of product names joined with arrows is insufficient.
4. **Connections:** every source/output port, destination/input port, object type and routing points. Explicit boundary wires are valid. Every internal port has exactly one connection. No dangling arrows or implicit junctions.
5. **Spatial layout:** direction, box bounds/coordinates, port placement, crossing conventions and feedback routes. For large systems, keep one whole-system view plus focused subdiagrams with the same stable IDs.
6. **Categorical notes:** what structural equalities or proven domain rewrites are encoded, and which plausible equations are deliberately not asserted.
7. **Color mapping:** one semantic family per domain/object class, consistent across every view. Use additional line/status marks so color is not the only distinction.

Treat the model as the single source for the rendered labels and wiring. For a large graph, validate references, matching types, port cardinality and layout bounds mechanically. Explain interpretation choices in the specification rather than silently decorating a dependency graph as a rigorous string diagram.

## Paint without losing the wiring

Read [references/p5-brush.md](references/p5-brush.md) when implementing the renderer. Verify the selected release/API before choosing script URLs or methods; the original prompt's `bleed`/`segment` names are not portable across releases.

- Expose seed, palette, bleed strength and jitter near the top of the sketch. Seed both random and noise for reproducibility.
- Use a warm off-white or pale-grey paper canvas with restrained grain. Respect the display host's outer-page theme/layout contract.
- Render wires with actual p5.brush splines/lines/strokes, dark charcoal/indigo/warm black, tapered pressure and restrained organic jitter. Fix endpoints at the declared ports. Jitter must never change connectivity.
- Render closed morphism shapes with actual watercolor fills, controlled edge bleed, pigment texture/granulation and modest optical layering. Use a coherent palette such as raw umber, sap green, indigo, rose madder, ochre and Payne's grey.
- Keep labels legible and subordinate to structure. Light hand-lettering/jitter is optional; crisp HTML/SVG text over the painted p5 layer is acceptable. Do not sacrifice reading size to fit a large graph.
- Prefer hover/focus highlighting, click-to-expand details, or slow flow animation. Support keyboard activation and reduced motion. A visual highlight is not simulated application execution.
- For a large map, provide fit/zoom/pan or focused views and a searchable component list. Keep each connection identifiable in detail.
- Include code comments relating the graph's objects, morphisms and special structure to the drawing code.
- If a runtime/library fails, show a clear error. Any fallback must identify itself; do not silently label a flat substitute as p5.brush watercolor.

## Verify and deliver

Validate the signature and connections, load the complete HTML in a real renderer, inspect the resulting image, check console/runtime failures and exercise the interactions. Distinguish checks performed from untested capabilities. Keep no server, daemon or watcher merely to display an artifact.

Deliver the Markdown specification first and the complete HTML sketch second. For a large sketch, linked complete artifacts are preferable to thousands of pasted code lines. If the host supports inline HTML visuals, show the finished diagram there as well. Keep installation-specific data in the generated artifacts, not in this reusable skill.
