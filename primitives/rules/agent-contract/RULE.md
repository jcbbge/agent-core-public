---
name: agent-contract
description: "The enforced contract for every agent-to-agent message and every spawned agent: the identity and reply block on each message, and the only three moves a spawned agent has. Loaded by every agent that sends or receives an agent message."
---

# The agent contract

**Josh, 2026-11-20: a hard-lined, strictly enforced contract between the agent sending a message and
the agent receiving it.** It binds every agent-to-agent message, from every agent, in both directions.
rexconfig's agent commands enforce it; this file is its one source.

## Every agent-to-agent message carries

1. **Who:** the sender's name.
2. **ID:** its agent ID.
3. **Tab:** which Rex tab it's in, by label and window ID.
4. **Rex identifiers:** session, pane (block) and host.
5. **How to reply:** the exact command that sends a response straight back to the sender's pane:
   `agent-send <session> <pane> <your name> "<message>"`, which follows this same contract.

`agent-send` stamps this block on every message itself and refuses to send without it. Only
`agent-send` sends a message between agents.

## A spawned agent

It exists to deliver one piece of provisioned work (research, a task, anything else) that ends in a
tangible artifact: a file, a code change or a written response. It has exactly three moves:

1. **Complete the task.**
2. **Report that the task is complete:** the result and the artifact, sent to the agent that sent it
   the work.
3. **Report a problem:** any issue, roadblock, friction point, ambiguity, question, failure or request
   for help, sent to the agent that sent it the work. Then it waits for the answer and does nothing
   until the answer arrives.

It does nothing else. It doesn't improvise, drift, work outside the provisioned scope, stall or quit.
Every message it sends goes back to the agent that sent it the work, and to no one else.

## Enforcement

- `agent-send` stamps the block, and refuses a message to an agent pane that lacks it.
- The turn hook (`agent-hook`) accepts only three turn ends from a spawned agent: completed (the
  report), problem reported (then the agent waits for the answer), or work in progress. Any other turn
  end, including one that addresses anyone other than its sender, is refused once and sent back.
- `agent-spawn` gives the spawned agent this contract, its sender's block, and how to reply.
