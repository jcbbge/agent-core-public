# Agents talk to agents through Rex

**Non-negotiable (Josh, 2026-11-10).** Every agent can reach every other agent, and every agent it starts
reports back to it directly, one to one, through Rex. No agent learns what another is doing by guessing,
waiting, or asking the human to relay. Rex is named here by Josh's ruling: it is the operator's terminal,
the one surface every agent and the human share.

## The parts

- **Session and block.** Rex sets `REX_SESSION` and `REX_BLOCK` in every terminal it opens. A block is one
  pane; its id is your address. `rex whoami --json` checks your connection; `rex window ls -s <session> --json`
  lists tabs, with each tab's blocks under `layers[].blocks[]`.
- **On a machine without the Rex server** (the VPS, hive), `rex` is a shim (`~/.local/bin/rex`) that runs the
  Mac's Rex through the always-on tunnel (`ssh m5`). The commands are identical. An ssh'd terminal has no
  `REX_*` variables: whoever starts you passes your session and block in your brief.

## The protocol

1. **Starting an agent.** Open it in a visible Rex tab, never hidden:
   `rex window new -s <session> <name> --focus=false --json -- <command>`. Keep the block id it returns.
   Its brief always includes: your name, your session and block (the reply address), and what to report.
2. **Sending a message.** Type it into the receiver's block and submit it:
   `rex send -s <session> -b <block> "FROM <your name>: <message>"` then
   `rex send-key -s <session> -b <block> Enter`.
   Every message starts with `FROM <name>:`, so it is never mistaken for the human.
3. **Reporting back.** An agent that was started reports to its starter the same way, unprompted:
   when it stops, finishes, needs a decision, or is blocked. One message per event, self-contained, plain
   words. Then it waits for the reply in its own pane.
4. **Replying.** Reply to the `FROM` sender's block. A message that needs an answer names the block to answer.
5. **Reading.** `rex capture -s <session> -b <block> --trim` reads what a pane shows. Use it to check a message
   landed, to answer a prompt a session cannot answer itself (such as a folder-trust prompt), or to see a
   session that has not reported. Reading screens is a fallback, never the channel.
6. **Same machine.** Claude Code sessions on one machine may also use their built-in session messaging
   (`ListAgents` / `SendMessage`). Rex stays the channel that works everywhere, across machines and harnesses.

## Never

- Never type into the human's own pane, and never write as the human. The human's words are only what the
  human typed.
- Greyed-out text in an agent's input box is that harness's suggested reply, not a message. Ignore it.
- Never leave a started agent without a reply address, and never end your work without telling your starter.
- Never drive another agent's work by approving for the human: relay the human's decision, not yours.
