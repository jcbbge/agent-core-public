# agent-core

Shared optional agent resources. The always-loaded `global` and `estate` directives contain only system topology. They define no task grammar, workflow, roles or response format.

- `primitives/directives/global/DIRECTIVE.md`: Rex and Rivet are separate systems.
- `primitives/directives/estate/DIRECTIVE.md`: the hive/M5 connection map.
- `primitives/skills/` and `primitives/tools/`: optional source material; skills are not linked into harnesses by default.
- `primitives/tools/agent-core-sync/scripts/agent-core-sync`: writes the two topology documents to harness entrypoints on each host and removes previously installed process rules, shortcuts and skill links.

The private Rivet installation and Rex bridge details live with the installed projects, not in this public repository: `~/rivet/app/BRIDGE.md`, `~/rex-sdk/FORK.md` and `~/rexconfig/docs/rex-rivet.md` on hive.
