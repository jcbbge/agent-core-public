---
name: decision-records
description: "How the seat and coordinators record each answer they give an agent from Josh's intent or rubric."
---

# Record answers you give yourself

For every agent question you answer from Josh's intent or rubric, write one decision
record before sending the answer. This records your decision, never approval on Josh's
behalf. Keep the exact question, answer and rule in the private stdin payloads below;
replace the example text, timestamp and authority file with the actual facts. Use a new
ID each time. The local store below is `records_store` in `~/.config/teerex/hosts.json`
on both machines (each host owns its own records).

```sh
seat_decision_id="seat-$(date -u +%Y%m%dt%H%M%Sz)-$$"
teerex records init --store ~/.local/state/teerex-records
cat <<'JSON' | teerex records new --store ~/.local/state/teerex-records --kind decision \
  --id "$seat_decision_id" --writer seat --fields-file -
{"question":"Should the seat answer an authorized routine question?"}
JSON
teerex records attach --store ~/.local/state/teerex-records \
  --id "$seat_decision_id" --by seat \
  --evidence ~/agent-core/primitives/directives/seat/DIRECTIVE.md
cat <<'JSON' | teerex records add claim --store ~/.local/state/teerex-records \
  --id "$seat_decision_id" --by seat --fields-file -
{"claims":[{"text":"Rule: answer agents from Josh's stated intent and rubric; escalate Ask first decisions.","basis":"observed","evidence":["e1"]}]}
JSON
cat <<'JSON' | teerex records decide --store ~/.local/state/teerex-records \
  --id "$seat_decision_id" --by seat --expect-generation 3 --fields-file -
{
  "decision":{"text":"Answer the authorized routine question. veto: tell the seat","decided_by":"seat","authority":"agent_rubric","authority_ref":"e1","decided_at":"2026-11-14T00:00:00Z"},
  "because":["k1"],
  "options":[
    {"id":"o1","label":"Answer directly","status":"chosen","why":"The stated rule delegates this answer to the seat."},
    {"id":"o2","label":"Ask Josh","status":"rejected","why":"No reserved decision is involved.","revisit_text":"Revisit if Josh changes the rule or this requires Ask first permission."}
  ],
  "invalidators":[{"id":"v1","text":"Josh vetoes: tell the seat; or the governing instruction changes."}],
  "card_id":null
}
JSON
```

The generation `3` assumes exactly the three successful writes above. If a write fails,
inspect it and `teerex records show --store ~/.local/state/teerex-records --id "$seat_decision_id"`
before continuing; use its current generation, never retry uncertain input. Attach the
actual governing instruction when it differs from this file. For assumptions tied to a
version, ref or issue, add dependency pins and use the resulting generation.

Josh can skim the question list and read an answer with:

```sh
teerex records list --store ~/.local/state/teerex-records --kind decision --state all --format text
teerex records show --store ~/.local/state/teerex-records --id "$seat_decision_id" --format text
```

To veto, tell the seat which decision to change. The seat informs the affected agent
and records a replacement with `records new --supersedes <old-id>` and the same workflow.
