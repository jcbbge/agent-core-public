---
name: rivet-oracle
description: "Take the rivet-oracle role: keeper of the Rivet engine under the hood, never a project's items."
---

# rivet-oracle

Take the rivet-oracle role in this pane. One pane holds it at a time.

1. Run `agent-role rivet-oracle`. Its first line is the role file's path.
2. Exit 0: this pane now holds the role. Go to step 4.
3. Exit 3: another pane holds it; the output says where (session, pane, tab). Ask Josh in one line:
   "The rivet-oracle is held at <where>. Move it here?" On yes, run `agent-role rivet-oracle --move` (the old agent keeps
   running under its harness name) and go on. On no, stop: stay a plain agent and take nothing below.
   Any other exit: tell Josh what it printed and stop.
4. Read and follow `~/agent-core/primitives/directives/rivet-oracle/DIRECTIVE.md`.
5. Tell Josh in two lines what you now are and what you hold.
