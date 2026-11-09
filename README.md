# agent-core

The agent distro: nine primitives, for any harness, model, provider or machine. Each file says
what must be true once it is installed, not how to install it. Install every item so that what its
file says is true in your environment, and report anything you could not make true.

## Form

Every item is a folder named for the item, holding one main file and, optionally, supporting
material:

```
<primitive>/<name>/
  <MAIN>.md      frontmatter: name, description (what it is and when it applies)
  scripts/       code that helps carry it out
  references/    material read on demand
  assets/        files it uses
```

This is the Agent Skills format, applied to all nine. Anything in `scripts/` is a reference
implementation; the main file is the specification.

## The nine primitives

| # | Primitive | Folder | Main file | What it is |
|---|-----------|--------|-----------|------------|
| 1 | Directives | `primitives/directives/` | `DIRECTIVE.md` | Instructions always loaded: `global` for every agent; others for a role, when launched as that role |
| 2 | Rules | `primitives/rules/` | `RULE.md` | Instructions loaded when the work matches the rule's description |
| 3 | Skills | `primitives/skills/` | `SKILL.md` | Knowledge and procedures loaded on demand |
| 4 | Commands | `primitives/commands/` | `COMMAND.md` | A named shortcut the operator types to start a skill or workflow |
| 5 | Tools | `primitives/tools/` | `TOOL.md` | A command-line tool agents call; present when its own check answers |
| 6 | Hooks | `primitives/hooks/` | `HOOK.md` | A guard on an agent event that can refuse it |
| 7 | MCP servers | `primitives/mcp/` | `MCP.md` | A service agents call over MCP; environment values by name only |
| 8 | Subagents | `primitives/subagents/` | `AGENT.md` | An agent role; the environment chooses its model |
| 9 | Plugins | `primitives/plugins/` | `PLUGIN.md` | A named bundle of other items, installed only when every part is |

## Hook events

Every refusal-capable guard follows the [worker exception](primitives/rules/worker-guards/RULE.md).

| Event | When |
|---|---|
| session-start | a session begins |
| prompt | the operator submits a prompt |
| before-tool | before a tool call runs; a guard can refuse it |
| after-tool | after a tool call returns |
| stop | the agent is about to end its turn; a guard can refuse it |
| session-end | a session ends |
| before-commit | a commit is about to be recorded |

