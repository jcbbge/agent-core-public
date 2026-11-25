# Brief template

A brief is the whole hand-off under the [agent contract](../../rules/agent-contract/RULE.md).
`start-work` refuses one missing any of these seven headings, or with a failing Handoff check. Aim for 40 lines; link details.

# Purpose and outcome
Why the work exists and the tangible result: a file, a code change or a written response.

# Parties
The receiver; the sender (name, session, pane, host); what each owes the other.

# Provisioning
Verified sources, decisions already made, access and exact locations. The numbered working list; its
last item is always: reap (every pane, tab, window and session it opened is closed or handed to a named
owner, and every worktree, branch, server and temp file it made is removed).

# Scope and authority
What is permitted, what is excluded, what must be left alone.

# Expected response and evidence
What comes back, and the live checks that prove it done.

# Escalation
A problem goes to the sender with `agent-send`; the receiver waits for the answer. A decision only Josh
can make goes by `agent-ask`. Three answered NQ turns with questions left: the work holds.

# Handoff check
1. Everything needed: yes. <what this brief provides and where>
2. Questions about next steps: none. <the next steps in order>
3. Ambiguity: none. <each detail with two readings and how this brief settles it>

The sender answers these from the receiver's seat before hand-off. If any answer fails, revise the
brief until all three pass. Each answer must explain why on its own line; the gate checks the form,
not the quality of the explanation.
