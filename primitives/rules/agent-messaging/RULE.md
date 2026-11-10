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
- `agent-send <session> <pane> <your name> <message...>`: one message, delivered whole. It locks the receiving
  pane, clears its input line, types `FROM <your name>: <message>` and presses Enter, so simultaneous senders
  never run together. The only way to send.
- `agent-read <session> <pane>`: what a pane shows now. Only to confirm delivery or to answer a prompt a
  session cannot answer itself. Reading screens is a fallback, never the channel.

## The protocol

1. Start agents with `agent-spawn`, never hidden. Their brief gives your name and address and what to report.
2. A started agent reports to its starter unprompted when it stops, finishes, needs a decision or is blocked:
   one self-contained message, plain words, then it waits for the reply in its own pane.
3. Reply to the `FROM` sender's address. A message that needs an answer says where to answer.
4. Agents on one machine may also use their harness's own session messaging; the three verbs work everywhere.

## Never

- Never type into the human's own pane, and never write as the human. Every message starts `FROM <name>:`.
- Greyed-out text in an agent's input box is that harness's suggestion, not a message.
- Never leave a started agent without a reply address; never end your work without telling your starter.
- Never approve for the human: relay the human's decision, not yours.

## Transport

The verbs run on the terminal multiplexer's command line (today Rex, whose server runs on the Mac). A machine
without that server gets forwarders for the three verbs that run them on the Mac (on hive, through the
always-on tunnel). Swapping the transport changes the three scripts, never this protocol.
