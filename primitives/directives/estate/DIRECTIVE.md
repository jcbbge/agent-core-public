---
name: estate
description: Host and connection map for Rex and Rivet.
---

# Hosts and connections

| Host | Role | Connection |
|---|---|---|
| `hive` | Linux VPS: compute, Rivet Engine and Services, node, Rex server, SDK and Rex config | local shell on hive; `ssh hive` from the M5 |
| `m5` | Mac: Josh's Rex app, its separate built-in Rex server and browser | `ssh m5` from hive |
| `m1` | Second Mac | reachability not established |

The M5 Rex app connects to hive's Rex server as a client; it also has its own local Rex server. Rivet's Rex bridge and the packaged Rex SDK connect to hive's Rex server. Rex config and Lua run on hive; the M5 app's local shortcuts are in `~/rexconfig/m5/rex/init.lua`. The private connection map is `~/rexconfig/docs/rex-rivet.md`; Rivet's service and bridge setup is documented in `~/rivet/app/BRIDGE.md` and the project README. Hive uses America/Chicago time.
