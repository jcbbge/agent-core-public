# Agent messaging

**Non-negotiable (Josh, 2026-11-10).** Every agent can reach every other agent, and every agent it starts
reports back to it directly, one to one. No agent learns what another is doing by guessing, waiting, or
asking the human to relay.

## Addresses

An agent's address is its **session** and **pane**. `AGENT_SESSION` and `AGENT_PANE` hold yours when your
terminal sets them; otherwise your brief gives them. Whoever starts you passes theirs as your reply address.

## The three verbs (agent-core `tools/agent-messaging`)

- `agent-spawn --brief-file <brief.md> [--owner <owner>] [--purpose <purpose>] <session> <name> -- <claude|codex|pi>`:
  start through `teerex agents launch` using `~/.config/teerex/profiles.json`. The caller's own pane is
  starter and report-to. Profiles supply harness argv, standing flags, job registry and fleet-board store.
  Only configured profiles work. The selected named host defaults to hive; set `TEEREX_HOST=m5`
  explicitly for M5-hosted panes. Caller and target addresses belong to the same selected server. `--non-agent` retains low-level
  `teerex spawn` only for an explicitly marked non-agent command.
- `agent-send <session> <pane> <your name> <message...>`: one message, delivered whole. It locks the receiving
  pane, clears its input line, types `FROM <your name>: <message>` and presses Enter, so simultaneous senders
  never run together. The only way to send.
- `agent-read <session> <pane>`: what a pane shows now. Only to confirm delivery or to answer a prompt a
  session cannot answer itself. Reading screens is a fallback, never the channel.

## The seat: where questions for the human go

The human talks to exactly one agent: **the seat** (the agent whose pane the human types in). Everything
meant for the human goes to the seat with `agent-send`, and only the seat asks the human anything.

- Every other agent sends a question or decision for the human to the seat, as one self-contained message
  (what, why it matters, the options, its recommendation), then keeps doing whatever does not depend on it.
- **No agent outside the seat ever stops on an on-screen prompt**: no question menus, no "choose an option"
  dialogs, no waiting on input in its own pane. A pane nobody watches is a dead end.
- The seat relays the human's answer word for word to whoever asked, with `agent-send`.
- Complete decision cards and their resolutions can use native `teerex ask`; it types into the
  addressed pane through guarded send. Read `teerex ask --help`; no seat inbox is required.
- If you do not know who the seat is, ask your starter. A brief always names the seat and its address.
- **Prepared questions.** A question for the seat also states three things, so it can be answered from
  the message alone:
  - **Checked:** what you already looked at (settings, prior decisions, evidence) and why that did not
    settle it.
  - **If no answer:** what you will and will not do while it is open. Silence never authorizes an option
    that is irreversible, destructive, security-relevant or outside your permission; those wait. A choice
    you would make on silence was yours to make: make it and report the reading instead of asking.
  - **Continuing:** the independent, authorized work that proceeds meanwhile, or "none" and why.
  With `teerex ask --deliver paste` these are the card's `prepared` fields; mark irreversible options.
- **Evidence by reference.** Point to private material (captures, transcripts, notes, logs) by path or
  ID; never paste it into a question, and never reuse it as an example, fixture or template without
  Josh's consent.
- **One question, sent when it blocks.** Send each blocking decision the moment it blocks, one per
  message. Non-blocking decisions wait for your report's *Decisions owed*.
- **Agents message the seat directly (Josh, 2026-11-13: "Disable the feature let agents communicate directly to
  you").** `agent-send` types into the seat's pane like any other pane, so every report reaches the seat as input
  and gets an answer. There is no seat inbox, log or board to check. `agent-send`'s typing guard waits while the
  human is typing in that pane and puts the draft back after the message.

## The protocol

1. Start agents with `agent-spawn`, never hidden. Their brief gives your name and address and what to report.
2. **A report is the agent's last message of its turn (Josh, 2026-11-13: "why is it repeating the same thing?").**
   When an agent stops, finishes, needs a decision or is blocked, it ends its turn with one self-contained
   message in plain words. teerex's stop report delivers exactly that text to its starter, once. Never also
   `agent-send` the same report. `agent-send` is for a question or decision needed while the work is still
   going.
3. Reply to the `FROM` sender's address. A message that needs an answer says where to answer.
4. **Conflicting permission.** When two sources of authority disagree (see the directive's order of
   authority), act on the narrower and send the conflict to the seat, naming both sources. Never resolve it
   by taking the broader reading. Work both permit proceeds.
5. Agents on one machine may also use their harness's own session messaging; the three verbs work everywhere.
6. **Acknowledge before the brief (Josh, 2026-11-11).** A started agent first gets only this protocol and its reply
   address, and records the supplied `teerex agents ack` command. Managed launch attempts the brief once only
   after that ACK. A deadline is reported honestly; inspect the tracked launch before retrying or closing.
7. **The launcher guarantees the alert, once.** Managed launch (`teerex agents launch`, the profile's
   `hook_events`) sends the starter the agent's last words when a turn ends, its error when the harness fails,
   and the exit when the process ends. It is the only stop alert: nothing else hooks Stop.
8. **Long output is a document, read in leaf (Josh, 2026-11-12).** Anything for the human longer than a few lines
   (a task list, a table, a QA brief, a report) is written as a `.md` file in the item's work folder, never printed
   into a pane. It is opened in `leaf` (a terminal document reader, installed on the Mac and on hive) in a pane
   beside the agent: `teerex surfaces open --layout tiled --anchor <agent pane> -- ssh -t hive 'leaf open <file.md>'`. An
   agent without that access sends the seat the file's path and the seat opens it. In Rex, Cmd+Shift+P → Leaf opens
   any document too.

## Never

- Never type into the human's own pane, and never write as the human. Every message starts `FROM <name>:`.
- Greyed-out text in an agent's input box is that harness's suggestion, not a message.
- Never leave a started agent without a reply address; never end your work without telling your starter.
- Never approve for the human: relay the human's decision, not yours.

## Transport

The wrapper commands use `~/.config/teerex/hosts.json` (`TEEREX_HOSTS` can select another file).
`TEEREX_HOST` selects the command host, default `hive`; no cross-host search or fallback occurs.
Native `surfaces resolve` resolves labels and suffixes before sends and reads.

The verbs are Rex, through teerex (jcbbge/teerex): `agent-spawn` uses `teerex agents launch` from configured profiles, `agent-send` is `teerex send`,
the fleet board is `teerex boards fleet`. Nothing is hand-built beside them; a gap is a teerex issue.
