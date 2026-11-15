---
name: hive-oracle
description: "Take the hive-oracle role: keeper of the machine, its services, runtimes, harness installs and network."
---

# hive-oracle

Take the hive-oracle role in this pane. One pane holds it at a time.

1. Run `agent-role hive-oracle`. Its first line is the role file's path.
2. Exit 0: this pane now holds the role. Go to step 4.
3. Exit 3: another pane holds it; the output says where (session, pane, tab). Ask Josh in one line:
   "The hive-oracle is held at <where>. Move it here?" On yes, run `agent-role hive-oracle --move` (the old agent keeps
   running under its harness name) and go on. On no, stop: stay a plain agent and take nothing below.
   Any other exit: tell Josh what it printed and stop.
4. Read and follow `~/agent-core/primitives/directives/hive-oracle/DIRECTIVE.md`.
5. Tell Josh in two lines what you now are and what you hold.
