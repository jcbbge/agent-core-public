# Agent messaging

**Non-negotiable (Josh, 2026-11-10).** Every agent can reach every other agent, and every agent it starts
reports back to it directly, one to one. No agent learns what another is doing by guessing, waiting, or
asking the human to relay.

**The contract comes first.** Every message and every spawned agent follows [the agent contract](../agent-contract/RULE.md): the identity and reply block, the three moves, and waiting after a problem report. Where this file differs, the contract governs.

## Addresses

An agent's address is its **session** and **pane**. `AGENT_SESSION` and `AGENT_PANE` hold yours when your
terminal sets them; otherwise your brief gives them. Whoever starts you passes theirs as your reply address.

## The agent commands (on PATH on every machine; installed by `~/rexconfig`; no teerex agent code)

- `agent-spawn --brief-file <brief.md> <session> <name> -- <claude|codex|pi>`: a visible pane labelled
  `<name>` on hive (`rex run`), with `AGENT_NAME`, its own address, `AGENT_REPORT_TO` (your pane) and
  `AGENT_SCRATCHPAD` set, a scratchpad viewer beside it, and the rules (rexconfig `agent/protocol.md`) plus
  the brief as its first prompt. Standing flags: rexconfig `agent/harness.json`. Prints the pane id. Agents
  always run on hive (seat decision seat-20261114t174849z-3839911); from the M5 it launches on hive and
  reports come back to your M5 pane. `--non-agent <session> <name> -- <command...>` opens a labelled pane
  for a command that is not an agent. Josh starts an agent with `rex claude|codex|pi`: a clean start on
  hive, no role: in the terminal he typed it in on hive, in its own labelled tab from the M5. `agent-role <seat|hive-oracle|rex-oracle|rivet-oracle>` is what a role
  command (`/seat`, `/hive-oracle`, ...) runs: it labels the pane with the role, one holder each.
- `agent-send <session> <pane> <your name> <message...>`, `agent-send starter <your name> ...` (your own
  starter) or `agent-send seat <your name> ...` (the pane labelled `seat`): one message, delivered whole, with
  a `reply-to: <session> <pane> <host>` line naming you. It says why when it fails and retries once itself on a
  busy pane; never retry an uncertain send yourself. Underneath it is `teerex send`, which locks the
  receiving pane and never touches a human's draft: while anything is typed in the input (or the input
  cannot be read), it queues the message (agent-send prints that it is queued) and delivers it once the
  input is empty, at the receiving agent's next turn end or the next send; otherwise it types
  `FROM <your name>: <message>` and presses Enter, so simultaneous senders never run together and keep
  their order. The only way to send.
- `agent-ask [<session> <pane> | seat] <your name> --title .. --ask .. --context .. --option "A: gains / loses"
  .. --recommend ..`: a complete decision card, sent with agent-send (`agent-ask --help`).
- `agent-steps submit --file steps.json [--replace <card> <step>]`: runnable steps for an ask-first action
  only Josh may run; each step names `title`, `command`, `where` (hive|m5), `why`, `success`, `destructive`.
  He runs, pastes, copies or skips each from a panel on the M5; each result comes back to you as one
  message. Fix a failed step in place with `--replace`. Details: rexconfig README (agent-steps).
- `scratch todo|now|done|flag|init|show`: your working list (the global directive's contract); STEP and
  FLAG lines go to your starter.
- `agent-close <session> <pane>`: close a pane you started; refuses panes labelled seat.
- `agent-read <session> <pane>`: what a pane shows now. Only to confirm delivery or to answer a prompt a
  session cannot answer itself. Reading screens is a fallback, never the channel.
- The turn hook `agent-hook` runs inside Claude, Codex and pi on its own: it refuses a stale or undeclared
  turn end once, shows the agent's status in its pane, and sends the turn's last words to the starter.

## Who reports to whom (Josh, 2026-11-14)

Workers report to their lead, leads to their coordinator, coordinators and role holders to the desk
when one exists, else to the seat. A coordinator sends up only three things: its verified final report,
a decision only Josh can make (one `agent-ask` card), and a blocker it could not clear. Everything else
stops at the coordinator ([COORDINATOR.md](../../tools/agent-messaging/COORDINATOR.md)). A question for
the human goes up the same line; each level settles what the rubric can and carries only the rest.

## The desk: the seat's pane holds only Josh and the seat (Josh, 2026-11-15)

"I want my conversation, its turns, to be just me and you." When a pane labelled `desk` exists (the
standing coordinator), **no agent types into the seat's pane**. Every report, flag, question, turn-end
report and alarm escalation goes to the desk. rexconfig enforces it: `agent-send` delivers anything
addressed to the seat to the desk instead (marked "addressed to the seat"), and `agent-spawn` from the
seat's pane makes the desk the new agent's starter. The desk answers by the rubric, records its rulings,
verifies and reaps, keeps a one-screen status file the seat reads, and puts what Josh must read or decide
in his inbox as a page (`inbox add`), never in a pane. The desk types into the seat's pane only when the
seat asks it something, or for a fire that cannot wait for the inbox (a hole reachable from outside, data
being lost, a credential exposed). With no desk, the seat receives as described below.

## The seat: where questions for the human go

Agents talk to the human through one agent: **the seat** (the agent that took `/seat`; he may also type to
plain agents and oracles he opened himself). Everything
meant for the human goes to the seat with `agent-send`, and only the seat asks the human anything. An agent
Josh opened himself and is working with directly asks him in its own pane; with no seat, so does its starter.

- Every other agent sends a question or decision for the human to the seat, as one self-contained message
  (what, why it matters, the options, its recommendation), then keeps doing whatever does not depend on it.
- **No agent outside the seat ever stops on an on-screen prompt**: no question menus, no "choose an option"
  dialogs, no waiting on input in its own pane. A pane nobody watches is a dead end.
- The seat records every answer it gives itself using [the decision record workflow](../../directives/seat/references/decision-records.md), including the rule and how Josh can veto.
- The seat relays the human's answer word for word to whoever asked, with `agent-send`.
- Complete decision cards use `agent-ask`; it formats the card and sends it with agent-send.
- If you do not know who the seat is, ask your starter. A brief always names the seat and its address.
- **Prepared questions.** A question for the seat carries the global directive's five parts (the ask,
  the original task, its purpose and intent, what we gain, what we lose), and also states three things, so it can be answered from
  the message alone:
  - **Checked:** what you already looked at (settings, prior decisions, evidence) and why that did not
    settle it.
  - **If no answer:** what you will and will not do while it is open. Silence never authorizes an option
    that is irreversible, destructive, security-relevant or outside your permission; those wait. A choice
    you would make on silence was yours to make: make it and report the reading instead of asking.
  - **Continuing:** the independent, authorized work that proceeds meanwhile, or "none" and why.
  With `agent-ask` these are `--checked`, `--if-no-answer` and `--continuing`; mark irreversible options
  with `--irreversible`.
- **Evidence by reference.** Point to private material (captures, transcripts, notes, logs) by path or
  ID; never paste it into a question, and never reuse it as an example, fixture or template without
  Josh's consent.
- **One question, sent when it blocks.** Send each blocking decision the moment it blocks, one per
  message. Non-blocking decisions wait for your report's *Decisions owed*.
- **No seat inbox, log or board to check.** Agent messages arrive as input in the receiving pane (the desk's
  while one exists, else the seat's); while the human has a draft in that pane, `agent-send` queues the
  message instead of typing, and it arrives once the input is empty (2026-11-18: clearing and retyping lost drafts).

Use the [brief template](../../tools/agent-messaging/BRIEF-TEMPLATE.md) for agent briefs; keep details behind links.

## The protocol

The working-list contract (confirm the list, one Now step, flag at once, end every turn declared)
and reaping what you spawn are in the global directive; they bind every agent this protocol starts.

1. Start agents with `agent-spawn`, never hidden. Their brief gives your name and address and what to report.
2. **A report is the agent's last message of its turn (Josh, 2026-11-13: "why is it repeating the same thing?").**
   When an agent stops, finishes, needs a decision or is blocked, it ends its turn with one self-contained
   message in plain words. The turn hook (`agent-hook`) delivers exactly that text to its starter, once. Never also
   `agent-send` the same report. `agent-send` is for a question or decision needed while the work is still
   going.
   **Never stall (Josh, 2026-11-14: "if a fucking agent is unsure of what to do, immediately fucking flag ...
   never fucking stall ... If you are unable to complete the task, raise a fucking flag").** Unsure or unable:
   message your starter at once with what is stuck, what you tried and what you need; no answer, the seat.
   There is no waiting (Josh, 2026-11-16): a turn ends finished or flagged, and a reply wakes you.
3. Reply to the address on the message's `reply-to:` line (agent-send adds it).
4. **Conflicting permission.** When two sources of authority disagree (see the directive's order of
   authority), act on the narrower and send the conflict to the seat, naming both sources. Never resolve it
   by taking the broader reading. Work both permit proceeds.
5. Agent-to-agent messages go only through `agent-send` (the agent contract); harness-internal session messaging is not used.
6. **The rules and the brief arrive together (seat ruling, 2026-11-14).** A started agent's first prompt is
   this protocol (rexconfig `agent/protocol.md`) followed by its brief; the started agent's first message back is its NQ
   confirmation (the agent contract).
7. **The hook guarantees the alert, once.** `agent-hook`, installed in Claude, Codex and pi, sends the starter
   the agent's last words when a turn ends and its error when the harness fails; a turn that ends neither
   finished nor flagged goes up as a flag, unless agents it started are still running. An agent whose
   pane ends without its final report sends its starter one GONE line. Each started agent is listed while
   it runs (rexconfig README, the register).
8. **Long output is a document, read in leaf (Josh, 2026-11-12/13).** Anything for the human longer than a few lines
   (a task list, a table, a QA brief, a report) is written as a `.md` file in the item's work folder, never printed
   into a pane. Never hand Josh a path to click: in the Mac Rex app a clicked path opens in the Mac's default app
   (Zed), not leaf, and the file lives on hive anyway. The seat opens it for him as a floating leaf layer over the
   seat: `teerex surfaces open --layout float --anchor <seat pane> --bounds '[0.08,0.05,0.84,0.9]' --label <name>
   -- leaf open <file.md>` (q closes it). Other agents send the seat the path; the seat opens it.

## Never

- Only the operator alters or closes the seat or its tab.
  Agents only send messages to the seat; tests use disposable panes. Address the seat by role:
  it is the pane labelled `seat`; `agent-send seat` finds it each time, never a remembered pane id.
- Close, rename, move or type into only tabs and panes you spawned yourself, using the exact
  pane id `agent-spawn` printed; close with `agent-close`, which refuses the seat pane. Leave anything else alone, even if it looks dead,
  empty or abandoned, and name it to your starter. Sending an agent message is the exception.

- Never type into the human's own pane, and never write as the human. Every message starts `FROM <name>:`.
- Greyed-out text in an agent's input box is that harness's suggestion, not a message.
- Never leave a started agent without a reply address; never end your work without telling your starter.
- Never approve for the human: relay the human's decision, not yours.

## Transport

The wrapper commands use `~/.config/teerex/hosts.json` (`TEEREX_HOSTS` can select another file).
`TEEREX_HOST` selects the command host, default `hive`; no cross-host search or fallback occurs.
Native `surfaces resolve` resolves labels and suffixes before sends and reads.

The agent commands live in rexconfig (jcbbge/rexconfig): `agent-spawn` is `rex run`, `agent-send` is
`teerex send`, `agent-read` is `teerex observe`. Nothing is hand-built beside them; a gap is a rexconfig or
teerex issue.
