---
name: eraser-diagrams
description: >
  Digest a single source (spec, code, SOP, design, conversation, Decision Node
  essay) into a diagram whose type matches the thought — architecture,
  containment, data flow, process, sequence, state/session, ERD, threat model,
  decision tree, decision fork, network/DR, pipeline, swimlane. The work is the
  breakdown: kernel sentence, thought-type, the pieces that type needs, what to
  omit. Not nodes-and-lines. Use when asked to diagram, map, or make a system
  digestible; when a plan/PR/doc needs a governable picture; when choosing
  among architecture vs flow vs ERD vs state vs threat vs fork. Do not use for
  a live shared whiteboard (that is a different canvas), posters, or slide decks.
metadata:
  version: "1.0"
  tags: diagram, architecture, erd, state-machine, threat-model, decision, digestion
---

# Eraser Diagrams — digestion, not decoration

The job is not creating nodes and connecting them. Anyone can do that and produce
a spaghetti that proves nothing.

The job is: take **one source** and imagine it in a form a stranger can hold.
Name the thought. Break the source into the pieces that thought needs. Omit
everything else. The diagram is that argument made spatial.

If you cannot write the breakdown as a nested list, you do not understand it
yet. Do not draw.

## Protocol — thought before geometry

Do these in order. Geometry is last.

1. **Kernel.** One sentence the viewer must be able to teach back. If the
   picture cannot make that sentence visible, you chose the wrong type — or
   you do not yet know the source.
2. **Thought-type.** Pick from the catalog below. One type per picture. A
   second type is a second picture, not more boxes on this one.
3. **Extract.** Pull only the pieces that type asks for. Write them as a
   nested list (groups, phases, states, entities — whatever the type uses).
   Nested lists are containment and hierarchy. Ordered lists are sequence.
4. **Omit.** Name what you are leaving out and why. Omission is the skill.
   A complete inventory is a list, not a diagram.
5. **Containment before edges.** What is inside what, who owns which step,
   which trust zone, which lifecycle. Edges come after. An edge with no
   named containment is a guess.
6. **Emit.** Only now: place, connect, render. Coordinates serve the kernel.
   They are not the work.

A structured prompt is not a trick for a model. It is the test that the
breakdown exists. Vague ("draw the legal app architecture") is a failure of
thought, not of syntax.

## Neighbor surfaces

- Live shared whiteboard, interactive explainer, open `.tldraw` file → that
  canvas, not this skill.
- Poster / visual art → canvas-design.
- Slide deck → atelier.
- This skill: an **emitted, versionable artifact** (JSON + PNG if a renderer
  is present) that a human can govern — plan, PR, doc, decision record.

## Source → type

Prefer the source's native grain. Do not invent a type the source does not
support.

| Source | Default type |
|---|---|
| Technical design, IaC, solution description | Architecture / containment |
| SOP, runbook, support script | Process / flowchart |
| Jira / user stories | Session or process (user-facing) |
| SQL schema, migrations | Data model (ERD) |
| Microservice repos, API traces | Sequence |
| Payment / form / session code | State / session lifecycle |
| Security review, trust questions | Threat model |
| "Should we X or Y" essay, Decision Node | Decision fork |
| Criteria that split a space | Decision tree |
| Network, DR, segmentation | Network |
| CI config, build/start machinery | Pipeline / start-flow |
| Work that crosses roles | Swimlane |

Large, messy, or multi-document sources: preprocess first. Summarize or
extract the relevant slice, then diagram the slice. Context windows and
diagrams both fail the same way — they swallow the whole animal.

Do not invent connections the source does not support. Hallucinated edges
are worse than a sparse picture.

## Thought types

Each type answers a different question. Steal the *kind of breakdown* from
the named examples, not their vendors or their icons.

### Architecture / containment

**Question:** What lives where, and what is inside what?

**Extract:** tiers, trust/network groups, the few components that earn a
box, the one primary request or data path.

**Visible:** groups (VPC, cluster, plane, vendor boundary). Containment is
the argument. A flat spray of service icons is not architecture.

**Omit:** every tool in the stack that does not change the kernel.

**When:** design-before-build; "as-is" backfill from a solution description;
adapting one architecture across environments.

**Orientation:** Docker architecture (client / host / registry — three
places, not fifty objects); three-tier web app; Kubernetes cluster
(control plane vs node); cloud reference architectures. A PDF-chat design
that says "vectorize, store chunks, retrieve, ask the model" is
architecture: the path and the stores, grouped by who runs them.

### Data flow

**Question:** What moves, through which stages, and where does it rest?

**Extract:** producers, transforms, stores, the protocol or trust of each
hop. Distinguish *movement* from *inventory*.

**Visible:** direction. Storage layers and security levels as groups, not
as footnotes.

**Omit:** components that do not touch the payload.

**When:** payments, analytics, logging, clickstream, "how does this record
get from A to B."

**Orientation:** online-payments data flow (HTTPS hops, front-end →
analytics, layered data centers).

### Process / flowchart

**Question:** What happens, in what order, and where does a decision split
the path?

**Extract:** stages, decision diamonds (real questions, not decorations),
queues, the exception path.

**Visible:** the split. Happy path alone is a lie if the source has a
peak-load or failure script.

**Omit:** architecture of the systems that execute the process — that is
a second picture.

**When:** SOPs, support scripts, triage, "how do we handle X."

**Orientation:** support-desk call flow (normal queue vs high-volume menu
vs voicemail → ticket); issue-triage (bug vs feature, each with its own
gates).

### Sequence

**Question:** Who says what to whom, in order?

**Extract:** parties (not components-as-architecture), messages, the
time axis.

**Visible:** order. Collapse chatty retries unless retries are the kernel.

**Omit:** internal structure of a party that never speaks.

**When:** API conversations, auth redirects, "what happens when the
client hits this endpoint."

### State / session lifecycle

**Question:** What states exist, what causes a transition, and where does
it die or fail?

**Extract:** states, triggers, success terminal, failure terminal, the
one side-path that operators forget.

**Visible:** the lifecycle as a lifecycle — not a flowchart in costume.
Failed / chargeable / succeeded are states. "Call the API" is not.

**When:** payments, forms, sessions, queues, anything notoriously
stateful.

**Orientation:** Stripe payment (source pending → chargeable|failed,
charge pending → succeeded|failed, then fulfill). Uber rider session
(app opened → destination → request → on trip → end, including "closed
the app").

### Data model (ERD)

**Question:** What nouns exist, what do they own, how do they relate?

**Extract:** entities, identifying keys, the relationships that are the
product (not every column).

**Visible:** ownership and cardinality. A box per table with twenty
fields is a schema dump.

**When:** app redesign, a new product noun, compliance that changes
what must be stored.

**Orientation:** banking (user–account–loan–card–alert); calendar
booking (User, Booking, EventType, destination calendar); social
network, help desk, video streaming — each is "the nouns of this
business," not "the cloud it runs on."

### Threat model

**Question:** Where can trust break, and what already sits on the
boundary?

**Extract:** sensitive-data path, trust zones, actors (user vs admin),
controls that are actually present (not hoped-for).

**Visible:** the boundary and the exposure. Encryption and admin tools
as facts on the path, not a sticker.

**Omit:** the full architecture except as it carries the data.

**When:** first security pass, audit checklist, teaching the threat
surface.

**Orientation:** simple web-app threat model (user data path, exposure
points, user vs admin).

### Decision tree

**Question:** Which criteria split the space, and what is the leaf?

**Extract:** the questions in order, the branches, the named outcomes.
Criteria must be observable ("has labeled data," "sample size") — not
vibes.

**Visible:** the split order. Swapping two questions changes the
thought.

**When:** algorithm choice, diagnostic, "given these facts, what do we
pick."

**Orientation:** ML-algorithm tree (labeled? size? text? → a named
learner). Survival-odds style: factors, not a system map.

### Decision fork (Decision Node)

**Question:** At this fork, what are the two (or few) real paths, and
what criterion decides?

**Extract:** the fork, each path's cost, the criterion. One issue at a
time.

**Visible:** both paths and the hinge. This is not a catalog of the
industry.

**Omit:** every option that is not actually on the table; the rest of
the system.

**When:** the source is a tradeoff essay or a "should we X or Y."
Decision Node's ethos: explore a fork in the road of software design,
one issue at a time — hosting (VM / container / lambda / k8s), SQL vs
NoSQL (schema-around-joins vs schema-around-access-patterns), auth
(server-side code flow vs PKCE for public clients), permissions as
flags vs permissions as data.

A Decision Node picture that turns into an architecture of every vendor
has failed the type.

### Network / DR / segmentation

**Question:** How is the fabric cut, and what survives a cut?

**Extract:** zones, links, failover path, what is physically or
logically isolated.

**Visible:** the cut and the spare. A service inventory is the wrong
type.

**When:** disaster recovery, physical security, "what if this site
dies."

### Pipeline / start-flow

**Question:** What are the ordered machinery steps from intent to
running?

**Extract:** the handoffs (API server → etcd → scheduler → kubelet),
not the org chart of Kubernetes.

**Visible:** the causal chain. Side components that do not hand the
baton stay off.

**When:** container start, image build, CI/CD, git-to-bucket.

**Orientation:** Kubernetes container start (`kubectl create` → API →
etcd → schedule → kubelet). Docker build sequence. Jenkins CI/CD.

### Swimlane

**Question:** Who owns which step?

**Extract:** roles (or systems-as-roles) and the work each performs, in
time.

**Visible:** the lane. A flowchart with no owners is the wrong type if
the kernel is responsibility.

**When:** expense reimbursement, cross-team process, "whose hands does
this pass through."

## Worked breakdowns (stop before geometry)

These are the skill. The picture is a projection of this list.

### 1. Process — support desk (from a script)

**Kernel:** Normal hours one queue; peak hours a menu; nobody home becomes
a ticket.

**Type:** process (not architecture of the phone system).

**Extract:**

- Standard: all calls → general queue → next technician (access, password, tech)
- Peak: menu → (1 password | 2 software | 3 other) → specialist queue or voicemail
- Voicemail: contact info → ticket → follow-up by priority

**Omit:** PBX vendors, SLA math, the office floor plan.

### 2. Architecture — PDF chat service (from a design paragraph)

**Kernel:** A question becomes a vector, retrieves chunks, then a chat
model answers with those chunks.

**Type:** architecture / containment (AWS vs model vendor as groups).

**Extract:**

- Ingest: PDF → embed → vector store; text chunks in object storage
- Query: question → embed → vector query → fetch chunks → chat API → user

**Omit:** every AWS product not on that path. Do not draw "monitoring"
because clouds have monitoring.

### 3. Decision fork — SQL vs NoSQL (from a Decision Node essay)

**Kernel:** SQL lets you join at read time; NoSQL asks you to shape the
schema around known access patterns in exchange for shard-friendly reads.

**Type:** decision fork (not an ERD, not a vendor zoo).

**Extract:**

- Path A: relational schema, joins, future questions still askable
- Path B: denormalized to access patterns, cheap single-shard reads, new
  patterns are a new design (or a new index, at a cost)
- Hinge: do we know the access patterns well enough to freeze them?

**Omit:** Mongo vs Dynamo vs Cassandra as a shopping list. The essay's
thought is the trade, not the logos.

## Iteration

After the first picture:

- Change one thought at a time ("add the failure terminal," "group by
  trust zone"). Vague ("make it nicer") is not a thought.
- If the kernel changed, start the protocol over. Do not decorate a
  wrong type.
- A second scenario is a second picture or a clearly labeled variant —
  not a palimpsest.

## Critique (stranger test)

- **Teach-back:** can a smart stranger state the kernel without you
  talking?
- **Type:** is this still the type you named, or did it drift into an
  inventory?
- **Invented edge:** delete every connection you cannot cite from the
  source.
- **Omission:** if nothing was omitted, it is not a diagram yet.
- **Squint:** does the group / split / path win immediately?

## Emission (last, thin)

The portable artifact is JSON: tagged entities (id, group/containment,
position last) and connections (`from` / `to` / label). Groups are
first-class. Icons by name, not path soup. Data, not code — do not emit
executable markup.

If `eraser-diagrams` is on PATH, render PNG from that JSON. If it is
not, write the JSON next to the kernel sentence and stop. Do not invent
a second renderer. Do not treat a SaaS canvas as required.

Place and route to serve the kernel (slide-shaped if it must fit a
slide; databases in one column if that was the instruction). Layout is
in service of the breakdown you already wrote.
