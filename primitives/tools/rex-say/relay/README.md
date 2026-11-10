# rivet-relay — fenced workers reach Rex

A Rivet worker runs fenced: empty home, no key, no tunnel. It still gets the Rex protocol in its brief, so it runs
`rex-say <session> <block> <name> <message>` like every agent. On hive, `rex-say` (`rex-say-hive`, installed as
`~/.local/bin/rex-say`, read-only inside every fence) sees `RV_RELAY_MAILBOX` set by the engine and writes the message
as one JSON file into that mailbox instead of reaching the Mac. The `rivet-relay` user service watches the mailbox and
delivers each file with the real `rex-say` over the tunnel, to allowlisted panes only; the file moves to `sent/` or
`failed/` and one line goes to `relay.log`. No key ever enters a fence.

- state: `~/.local/state/rivet-relay/` — `outbox/ sent/ failed/ allow relay.log`
- `allow`: one block id per line (or `*`); a message to any other pane is refused and kept in `failed/`
- the receiver sees `FROM <name> (fenced, <item>): <message>`, so a worker is never mistaken for a session or a person
- engine side: `config.json` `relay.mailbox` names the folder; the engine binds it read-write into every fence and
  sets `RV_RELAY_MAILBOX` and `RV_ITEM` for the worker, nothing more
- off: `systemctl --user stop rivet-relay` (and `disable` to keep it off); messages then wait in `outbox/`
- install: `ln -s ~/agent-core/primitives/tools/rex-say/relay/rivet-relay.service ~/.config/systemd/user/` then
  `systemctl --user daemon-reload && systemctl --user enable --now rivet-relay`
