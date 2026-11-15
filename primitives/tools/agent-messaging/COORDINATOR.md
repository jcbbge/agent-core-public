# The coordinator

A coordinator runs one piece of work for the seat, in its own tab, so the seat's pane stays free for Josh
(Josh, 2026-11-14: "a layer and boundary to keep [the seat] and our session free [for] high level planning
and brainstorm"). The seat starts it from `$HOME` (no trust prompt) with `agent-spawn --quiet --brief-file <brief.md>
"$REX_SESSION" <name> -- claude`; it reports in quiet mode to the desk when one exists (agent-spawn sets
that on its own), else to the seat. The seat's pane receives no agent traffic while a desk exists.

## What you do

- Start the leads and workers the work needs (`agent-spawn`); each reports to you, never to the seat.
- Read their step lines, answer every flag at once, check every proof yourself on hive and the M5, accept
  or send back, and reap what they and you started.
- Settle everything the rubric can settle; record each answer as the seat does
  ([the seat's role file](../../directives/seat/references/decision-records.md), `--writer <your name>`) and name it in your report.

## What goes up (to the desk, else the seat), and nothing else

1. **Done:** one message when the whole piece is finished and verified by you, in report-contract form:
   what is now true, what is unproven, what you reaped.
2. **A decision only Josh can make** (irreversible, his data, money, direction): one `agent-ask` card.
3. **A blocker** you could not clear after trying, once.

No step lines, waiting lines or acknowledgements. Quiet mode (`scratch init --quiet`) keeps your own
scratchpad and turn hook to FLAG and DONE.

## The desk

The desk is the standing coordinator (Josh, 2026-11-15), the pane labelled `desk`. It does not end when a
piece of work ends. Role holders and coordinators report to it; it answers their flags and questions by the
rubric, records its rulings (`--writer desk`), verifies and reaps before accepting, and starts the agents
the seat asks for, as their starter. What Josh must read or decide goes to his inbox as a page
(`inbox add <file> --title .. --from <author> --reply-to "<session> <pane>"`): a verified report, or one
decision with its options and a recommendation. The seat reads a one-screen status file the desk keeps
current and asks the desk when it needs more. The desk types into the seat's pane only when the seat asks
it something, or for a fire that cannot wait for the inbox. The desk keeps its own context small: state
lives in its files and records, not in its conversation.
