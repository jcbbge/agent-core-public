# Agent messaging

**Non-negotiable (Josh, 2026-11-10).** Every agent can reach every other agent, and every agent it starts
reports back to it directly, one to one. No agent learns what another is doing by guessing, waiting, or
asking the human to relay.

## Addresses

An agent's address is its **session** and **pane**. `AGENT_SESSION` and `AGENT_PANE` hold yours when your
terminal sets them; otherwise your brief gives them. Whoever starts you passes theirs as your reply address.

## The three verbs (agent-core `tools/agent-messaging`)

- `agent-spawn <session> <name> -- <command...>`: start an agent in a new visible tab. Prints the new pane.
  The command runs with `AGENT_SESSION`/`AGENT_PANE` set to the new pane's own address; to start an agent on
  another machine, pass them along (`ssh -t host "export AGENT_SESSION=$AGENT_SESSION AGENT_PANE=$AGENT_PANE; ..."`).
  Without that export only the `LC_` forms cross ssh: then your address is `LC_REX_SESSION` / `LC_REX_BLOCK`, and
  your name and starter are `LC_AGENT_NAME` / `LC_AGENT_REPORT_TO`. `agent-spawn` falls back to your `LC_` address
  on its own.
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
- If you do not know who the seat is, ask your starter. A brief always names the seat and its address.
- **The seat's pane is never typed into (Josh, 2026-11-11: "i cant type without the agents message overwriting my
  words").** The seat is registered with teerex (`teerex boards seat register`). `agent-send` to it is kept in its
  inbox instead of being typed; `teerex boards inbox` shows the inbox to the human beside the seat, and the seat
  reads it when it works. One inbox: the old `~/.local/state/agent-inbox/seat-inbox.log` is moving into teerex's
  (2026-11-13), never kept beside it. Senders change nothing: same verb, same address.

## The protocol

1. Start agents with `agent-spawn`, never hidden. Their brief gives your name and address and what to report.
2. A started agent reports to its starter unprompted when it stops, finishes, needs a decision or is blocked:
   one self-contained message, plain words, then it waits for the reply in its own pane.
3. Reply to the `FROM` sender's address. A message that needs an answer says where to answer.
4. Agents on one machine may also use their harness's own session messaging; the three verbs work everywhere.
5. **Acknowledge before the brief (Josh, 2026-11-11).** A started agent first gets only this protocol and its reply
   address, and acknowledges by `agent-send` to its starter. The brief comes after the acknowledgement. An agent
   that never acknowledges is killed and reported.
6. **The launcher guarantees the alert.** An agent can die or go idle without reporting, so its launcher makes
   sure the starter hears: `agent-spawn` carries `AGENT_NAME` and `AGENT_REPORT_TO`, and the harness's stop and
   stop-failure hooks run `agent-stop-alert`, which sends the starter the agent's last words or its error. A
   starter watches its own inbox; it never waits to be prompted.
7. **Long output is a document, read in leaf (Josh, 2026-11-12).** Anything for the human longer than a few lines
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

The verbs are Rex, through teerex (jcbbge/teerex): `agent-spawn` is `teerex spawn`, `agent-send` is `teerex send`,
the seat and its inbox are `teerex boards`. Nothing is hand-built beside them; a gap is a teerex issue.
