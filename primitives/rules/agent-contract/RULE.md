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

## NQ: every hand-off (Made Well FOUNDATION.md, "NQ protocol"; Josh, 2026-10-16 and 2026-11-20)

Source: https://github.com/jcbbge/madewell/blob/main/FOUNDATION.md#nq-protocol-every-agent-to-agent-exchange.
Every interaction in which one agent hands anything to another is an NQ exchange. No exceptions:
spawns, assignments, answers, failure reports, return reports and replacement handoffs all count.

1. **The sender provisions in full.** The hand-off states: the purpose and outcome; who owes what to whom;
   the provisioning (verified sources, existing decisions, resources, access and exact locations); scope and
   authority (what is permitted, what is excluded); the expected response and its evidence; and how
   problems escalate. The receiver must never have to rediscover facts or fill gaps the sender should have
   covered. A gap the sender should have filled is the sender's defect to repair.
2. **The receiver confirms before it executes.** It states its understanding and answers three questions:
   What is unclear? What is ambiguous? Do I have everything I need to proceed? If nothing is unclear,
   nothing is ambiguous and it has everything, it proceeds at once. Otherwise it asks its sender (move 3),
   and waits.
3. **Each answer from the sender completes one turn.**
4. **Three turns, then stop.** If the receiver still has questions after three answered turns, the spec,
   brief or scope is wrong. That one piece of work holds and the human is alerted through the seat.
   Nothing else stops. No fourth answer and no reset, even in full autonomy.
5. **The spawner is responsible.** "If an agent spawns another agent, they are responsible. This is a
   top-down cascade." The spawner answers for the exchange and puts the receiver's understanding, the
   answers and the result in its own report.

## A spawned agent

It exists to deliver one piece of provisioned work (research, a task, anything else) that ends in a
tangible artifact: a file, a code change or a written response. It has exactly three moves:

1. **Complete the task**, after its NQ confirmation.
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
- `agent-spawn` refuses a brief missing any NQ provisioning field, and gives the spawned agent this contract,
  its sender's block and how to reply.
- A spawned agent's first message is its NQ confirmation (its understanding and the three questions).
  `agent-send` and the hook count answered NQ turns per exchange; a fourth question holds that work and
  alerts the seat.
