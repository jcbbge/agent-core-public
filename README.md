# agent-core

Shared optional agent resources. No globally loaded directives or generated harness entrypoints are installed; opening a Rex session or discussing a focus does not prescribe an agent workflow.

- `primitives/skills/` and `primitives/tools/`: optional source material; skills are not linked into harnesses by default.
- `primitives/tools/agent-core-sync/scripts/agent-core-sync`: removes only agent-core-owned generated harness entrypoints and its old process-rule, shortcut and skill links on each host; it preserves unowned settings and hooks.

Technical connection documentation lives in the installed private projects, not in always-loaded instructions: `~/rexconfig/docs/rex-rivet.md` (two Rex servers), `~/rivet/app/BRIDGE.md` (Rivet control and SDK-backed Rex messages), and `~/rex-sdk/FORK.md` (SDK integration) on hive.
