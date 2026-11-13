# Fenced delivery

Fenced launches use teerex's launch-scoped delivery channel. The supervisor supplies
`AGENT_CHANNEL` and the fixed starter/report-to addresses. Mount only that channel's
private directory read-only into the fence; keep the Rex socket and agent registry outside.


`agent-send` uses `teerex agents channel --operation send` for those fixed addresses.
Each message gets a fresh request ID. A refused or uncertain send is never retried.
The channel's supervisor supplies the sender name; the caller cannot change it.

The `agent-send-hive` and `agent-spawn-hive` files are compatibility entrypoints only.
There is no mailbox, polling relay or relay service.
