
# Rex ideas: install

AC=~/work/agent-core-rex            # or ~/agent-core once merged
REX='/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex'   # on the Mac

## 0. Check the shapes (hive; uses the Mac server through the shim)
rex block types --json
rex api describe block_creator.list
rex api describe session.new_block --json
rex api describe session.new_layer --json
rex api describe session.view --json
rex api describe session.list_blocks --json
rex api describe com.superlogical.terminal.program_status --json
rex api describe com.superlogical.terminal.set_theme --json
rex api describe com.superlogical.terminal.format --json
rex block ls -A --json | head -c 600
rex client ls
# Set CLIENT to the Mac app client label printed above.
rex actions -C "$CLIENT" --json | jq '.[] | select(.name=="session.select")'
If any shape differs from PLAN.md's table (C1–C12), send the output to the implementer before going on.

C7: `rex events -s "$AGENT_SESSION" --json` while a Claude agent works; stop with Ctrl-C.
C11 after reload: `rex keymap | grep -E 'cmd\+(shift\+)?[ji]'`.

## Before anything: back up what is replaced

Before the Mac copies above, create destination folders if absent:
```sh
ssh m5 'mkdir -p ~/.config/rex ~/.local/bin ~/Library/LaunchAgents ~/Library/Logs'
```

ssh m5 'cd ~/.config/rex && cp init.lua init.lua.bak-rex-ideas && ls -l ~/.local/bin/agent-send ~/.local/bin/agent-spawn'
ssh m5 cat .config/rex/init.lua | diff - ~/research/tabs/mac-init.lua   # must be empty; if not, merge by hand first
ssh m5 'cd ~/.local/bin && cp -P agent-send agent-send.bak-rex && cp -P agent-spawn agent-spawn.bak-rex'

## 13. Rex context for agents (hive)
mkdir -p ~/.local/bin && ln -sf $AC/primitives/hooks/rex-context/scripts/rex-context ~/.local/bin/rex-context
cp ~/.claude/settings.json ~/.claude/settings.json.bak-rex 2>/dev/null || echo '{}' > ~/.claude/settings.json
jq '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks":[{"type":"command","command":"'$HOME'/.local/bin/rex-context"}]}])' \
  ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
Verify: start `claude` on hive; its first answer to "what do you know about rex api?" cites the cache path.
Undo: mv ~/.claude/settings.json.bak-rex ~/.claude/settings.json

## 5. Flight recorder (hive)
ln -sf $AC/rex/bin/rex-flight ~/.local/bin/rex-flight
mkdir -p ~/.config/systemd/user && cp $AC/rex/systemd/rex-flight@.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now rex-flight@mac
Verify: rex-flight show -n 5   (after any agent changes state)
Undo: systemctl --user disable --now rex-flight@mac

## 7. Typing guard (Mac)
scp $AC/primitives/tools/agent-messaging/agent-send m5:.local/bin/agent-send.new
ssh m5 'cd ~/.local/bin && rm -f agent-send && mv agent-send.new agent-send && chmod +x agent-send'
Verify: the calibration in PLAN.md section 7.
Undo: ssh m5 'cd ~/.local/bin && rm agent-send && mv agent-send.bak-rex agent-send'

## 14, 11, 4, 9, 10. Rex config, watcher, palette, fleet, inbox layer, tints (Mac and hive)
scp $AC/rex/init.lua $AC/rex/watch.lua m5:.config/rex/
scp $AC/rex/bin/rex-hive-sync $AC/primitives/tools/agent-messaging/agent-launch m5:.local/bin/
scp $AC/primitives/tools/agent-messaging/agent-spawn m5:.local/bin/agent-spawn.new
scp $AC/rex/launchd/local.rex-watch.plist m5:Library/LaunchAgents/
ssh m5 'bash -s' <<'EOF'
cd ~/.local/bin && rm -f agent-spawn && mv agent-spawn.new agent-spawn && chmod +x agent-spawn agent-launch rex-hive-sync
REX='/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex'
"$REX" config check || { cp ~/.config/rex/init.lua.bak-rex-ideas ~/.config/rex/init.lua; exit 1; }
~/.local/bin/rex-hive-sync        # writes hive.lua and reloads; if it exits 2, see step 11 below
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.rex-watch.plist
EOF
Step 11 if rex-hive-sync exits 2: look at ~/.config/hive/launch; write ~/.config/hive/actions.tsv
  (name<TAB>title<TAB>command per entry), then run it again.
On hive (agent-seat, agent-inbox come from agent-core through the existing symlinks): nothing to copy if
  ~/.local/bin/agent-seat and agent-inbox point into $AC; otherwise ln -sf them as the relay README does.
Verify: PLAN.md sections 14, 11, 4, 9, 10, "Mac" tests, in that order.
Undo (all five):
ssh m5 'bash -s' <<'EOF'
launchctl bootout gui/$(id -u)/local.rex-watch; rm -f ~/Library/LaunchAgents/local.rex-watch.plist
cd ~/.config/rex && cp init.lua.bak-rex-ideas init.lua && rm -f watch.lua hive.lua
cd ~/.local/bin && rm agent-spawn && mv agent-spawn.bak-rex agent-spawn && rm -f agent-launch rex-hive-sync
'/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex' config reload
EOF
(agent-seat falls back to the split on its own when the layer call fails; the agent-inbox title is harmless.)

## 12. Rex server on hive (last)
On hive:
curl -fsSL https://pkgs.superlogical.com/rex/install.sh | sh -s -- --dry-run     # read it, then:
curl -fsSL https://pkgs.superlogical.com/rex/install.sh | sh
cp ~/.local/bin/rex ~/.local/bin/rex.mac-only && cp $AC/rex/bin/rex ~/.local/bin/rex && chmod +x ~/.local/bin/rex
/usr/bin/rex version
mkdir -p ~/.config/rex && cp $AC/rex/init.lua $AC/rex/watch.lua ~/.config/rex/
ssh m5 cat .config/rex/hive.lua > ~/.config/rex/hive.lua 2>/dev/null || true
for f in rex-hive-sync; do ln -sf $AC/rex/bin/$f ~/.local/bin/$f; done
ln -sf $AC/primitives/tools/agent-messaging/agent-launch ~/.local/bin/agent-launch
loginctl enable-linger
systemctl --user enable --now rex                      # the package's personal-server user unit
/usr/bin/rex server status                             # shows the socket: expect /run/user/1000/rex/server.sock
/usr/bin/rex config check
cp $AC/rex/systemd/rex-watch.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now rex-watch rex-flight@hive
On the Mac:
scp $AC/rex/launchd/local.rex-hive-forward.plist m5:Library/LaunchAgents/
ssh m5 'launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.rex-hive-forward.plist; sleep 3; ls -l ~/.ssh/rex-hive.sock'
ssh m5 "'/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex' hosts add hive unix:///Users/jrg/.ssh/rex-hive.sock && '/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex' -S hive ls"
In Rex for Mac (by hand, once): Add Remote Host… → /Users/jrg/.ssh/rex-hive.sock
Then open a session on the hive host. In it: `echo $REX_SESSION` is set; `rex ls` answers with no ssh;
  `rex skill setup --agent claude` once on hive.
Verify: from a hive-server tab, agent-send to a hive-server pane delivers locally (no m5 in `ps` during it);
  agent-send to a Mac-session pane still forwards to the Mac.
Rollback (each line is safe on its own; sessions on the hive server end):
systemctl --user disable --now rex-watch rex-flight@hive rex
loginctl disable-linger
cp ~/.local/bin/rex.mac-only ~/.local/bin/rex
ssh m5 "launchctl bootout gui/\$(id -u)/local.rex-hive-forward; rm -f ~/Library/LaunchAgents/local.rex-hive-forward.plist ~/.ssh/rex-hive.sock; '/Users/jrg/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex' hosts remove hive"
In Rex for Mac: remove the hive host.
Optional: sudo apt remove rex
agent-send-hive and agent-spawn-hive need no rollback: with no hive server they forward to the Mac as before.


Additional shape checks (step 0):
```sh
rex client ls
rex events -s "$AGENT_SESSION" --json # C7: watch while Claude works; Ctrl-C when captured
rex keymap | grep -E 'cmd\+(shift\+)?[ji]' # C11: after reload
```

C1–C12 are assumed shapes; verify against PLAN.md before using the configuration.
The hive server creates separate sessions; existing Mac sessions stay on the Mac until closed.
The existing config has no Mac-only osascript actions. The iOS app cannot use the SSH-forwarded socket.
If the package has no rex user unit (`systemctl --user cat rex`), add `ExecStartPre=/usr/bin/rex server start` to rex-watch.service.


## Seat checks in detail

Run these from hive unless a step says to use the Mac app. They require the live server and real panes.

### 7. Calibrate draft preservation

In an idle agent pane, type a few words without Enter. In another hive shell, use that pane's address:
```sh
agent-send "$S" "$P" test "guard check"
```
Expect a 30-second pause, then the message, then the original words back in the input line.
If it misreads the box, capture the exact screen and return it to the implementer:
```sh
rex block call -s "$S" -b "$P" format '{"format":"vt"}' > ~/guard-sample.json
```

### 14. Triage and stable waiting-agent navigation

```sh
rex config check
rex keymap | grep triage
rex do ~/.config/rex/init.lua --action next_waiting direction=prev
```
The keymap has seven triage bindings and the mode is exclusive. With three waiting agents,
repeated Cmd+J visits all three. Cmd+Shift+J enters triage; j/k walk both ways, z zooms,
Space toggles Activity, d dismisses a fleet agent, i toggles the inbox, Enter/Escape leave.

### 11. Hive palette

If the generator cannot parse the launch menu, create `~/.config/hive/actions.tsv` with
name, title, command separated by tabs. On hive, inspect generated output:
```sh
"$AC/rex/bin/rex-hive-actions"
```
The default sync source is `~/agent-core` on hive; for this unmerged checkout, run:
```sh
ssh m5 "AC_HIVE='~/work/agent-core-rex' ~/.local/bin/rex-hive-sync"
rex do spawn_agent name=launch-test brief="Say hi to your reply address with agent-send, then stop."
```
A visible hive Claude tab opens and replies to the launching pane. For palette refreshes before merging,
the Mac Rex server's environment must also set AC_HIVE to this checkout; after merging the default needs no override.

### 4, 9, 10. Fleet, floating inbox and tints

Start a detached Claude agent that waits for input; it stays out of sight while working and appears below
its starter when blocked, error or done. It becomes amber/red/green respectively. Working again detaches it
unless focused; focusing a done pane clears its tint. Dismiss it with triage d. Close it and verify its
`~/.local/state/rex-fleet/<block UUID>.anchor` disappears on the server host.

From a fresh `ssh hive` tab, verify the inbox floats over the right third. Cmd+Shift+I hides/shows it.
Hide it, then use `agent-ask` to send a test decision to the seat: it rises and focus remains in the seat.
If the layer API fails, verify the previous split-and-resize behavior still opens the viewer.

On hive, ensure the modified messaging tools and forwarders are actually selected:
```sh
for f in agent-seat agent-inbox; do
  ln -sf "$AC/primitives/tools/agent-messaging/$f" "$HOME/.local/bin/$f"
done
for f in agent-send agent-spawn; do
  ln -sf "$AC/primitives/tools/agent-messaging/relay/$f-hive" "$HOME/.local/bin/$f"
done
```
Record existing symlink targets before these commands; undo by restoring those targets.
