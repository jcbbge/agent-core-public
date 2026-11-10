# agent-relay — fenced workers reach their starters

A fenced worker (empty home, no key, no tunnel) still gets the agent-messaging protocol in its brief, so it runs
`agent-send <session> <block> <name> <message>` like every agent. On the worker host, `agent-send` is
`agent-send-hive` (installed as `~/.local/bin/agent-send`, read-only inside every fence): with `RV_RELAY_MAILBOX` set
by the engine it writes the message as one JSON file into that mailbox instead of reaching the operator's machine.
The `agent-relay` user service watches the mailbox and delivers each file with the real `agent-send`, to allowlisted
panes only; the file moves to `sent/` or `failed/` and one line goes to `relay.log`. No key ever enters a fence.

- state: `~/.local/state/agent-relay/` — `outbox/ sent/ failed/ allow relay.log`
- `allow`: one block id per line (or `*`); a message to any other pane is refused and kept in `failed/`
- the receiver sees `FROM <name> (fenced, <item>): <message>`, so a worker is never mistaken for a session or a person
- engine side: `config.json` `relay.mailbox` names the folder; the engine binds it read-write into every fence and
  sets `RV_RELAY_MAILBOX` and `RV_ITEM` for the worker, nothing more
- off: `systemctl --user stop agent-relay` (and `disable` to keep it off); messages then wait in `outbox/`
- install: `cp agent-send-hive ~/.local/bin/agent-send`;
  `ln -s ~/agent-core/primitives/tools/agent-messaging/relay/agent-relay.service ~/.config/systemd/user/` then
  `systemctl --user daemon-reload && systemctl --user enable --now agent-relay`
