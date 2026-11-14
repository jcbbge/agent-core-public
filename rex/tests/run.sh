#!/usr/bin/env bash
# Syntax and pure input contracts for the retained Rex integration.
set -euo pipefail
cd "$(dirname "$0")/../.."
SCRIPTS=(primitives/hooks/engine-host/scripts/engine-host rex/tests/run.sh)
for f in "${SCRIPTS[@]}"; do bash -n "$f"; done
printf 'PASS bash syntax\n'
if command -v shellcheck >/dev/null; then
  shellcheck "${SCRIPTS[@]}"
  printf 'PASS shellcheck\n'
else printf 'SKIP shellcheck (unavailable)\n'; fi
python3 - <<'PY'
import json, subprocess
hook='primitives/hooks/engine-host/scripts/engine-host'
deny=('rex capture -s session:x -b block:x', 'rex --server unix:///missing capture', 'rex -S hive block capture -s s -b b',
      'cd ~ && rex capture -s s', 'X=1 rex capture', 'echo $(rex capture -s s)', 'ls\nrex capture',
      '"/Applications/Rex Server.app/Contents/MacOS/rex" --autostart=false capture -s s')
allow=('echo hello', 'echo rex capture', 'rex block ls --json', 'echo "unclosed',
       'agent-send s b me "engine-host refuses rex capture whenever teerex is installed"', "git commit -m 'stop using rex capture'")
for command in deny+allow:
    r=subprocess.run([hook,'hook','claude'],input=json.dumps({'tool_name':'Bash','tool_input':{'command':command}}),text=True,capture_output=True,check=True)
    if command in deny:
        assert json.loads(r.stdout)['hookSpecificOutput']['permissionDecision']=='deny',(command,r)
    else: assert not r.stdout,(command,r)
r=subprocess.run([hook,'hook','claude'],input='invalid',text=True,capture_output=True,check=True)
assert not r.stdout,r
print('PASS capture refusal without pane/socket and allow on malformed hook input')
PY
