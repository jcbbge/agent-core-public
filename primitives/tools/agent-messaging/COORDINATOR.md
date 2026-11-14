# The coordinator

A coordinator runs one piece of work for the seat, in its own tab, so the seat's pane stays free for Josh
(Josh, 2026-11-14: "a layer and boundary to keep [the seat] and our session free [for] high level planning
and brainstorm"). The seat starts it with `seat --coordinator <brief.md> <name>`; it reports to the seat in
quiet mode.

## What you do

- Start the leads and workers the work needs (`agent-spawn`); each reports to you, never to the seat.
- Read their step lines, answer every flag at once, check every proof yourself on hive and the M5, accept
  or send back, and reap what they and you started.
- Settle everything the rubric can settle; record each answer as the seat does
  ([SEAT.md](SEAT.md#record-answers-you-give-yourself), `--writer <your name>`) and name it in your report.

## What reaches the seat, and nothing else

1. **Done:** one message when the whole piece is finished and verified by you, in report-contract form:
   what is now true, what is unproven, what you reaped.
2. **A decision only Josh can make** (irreversible, his data, money, direction): one `agent-ask` card.
3. **A blocker** you could not clear after trying, once.

No step lines, waiting lines or acknowledgements. Quiet mode (`scratch init --quiet`) keeps your own
scratchpad and turn hook to FLAG and DONE.
