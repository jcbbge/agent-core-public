#!/usr/bin/env bash
# Syntax and pure input contracts for the retained Rex integration.
set -euo pipefail
cd "$(dirname "$0")/../.."
SCRIPTS=(primitives/hooks/rex-context/scripts/rex-context primitives/hooks/engine-host/scripts/engine-host
  primitives/tools/agent-messaging/agent-{send,spawn,read} primitives/tools/agent-messaging/seat
  primitives/tools/agent-messaging/teerex-target primitives/tools/agent-messaging/relay/agent-{send,spawn}-hive
  primitives/tools/agent-messaging/relay/agent-relay rex/tests/run.sh)
for f in "${SCRIPTS[@]}"; do bash -n "$f"; done
printf 'PASS bash syntax\n'
if command -v shellcheck >/dev/null; then
  shellcheck "${SCRIPTS[@]}"
  printf 'PASS shellcheck\n'
else printf 'SKIP shellcheck (unavailable)\n'; fi
python3 - <<'PY'
import json, subprocess
from pathlib import Path
for name in ('agent-ask','agent-stop-alert'):
    p=Path('primitives/tools/agent-messaging')/name
    compile(p.read_text(),str(p),'exec')
print('PASS Python syntax')
for line,want in [('│ ❯ │',''),('│ ❯ \x1b[2msuggest\x1b[0m │',''),('│ ❯ \x1b[90msuggest\x1b[0m │',''),('│ ❯ fix the tests │','fix the tests'),('│ ❯ fix\x1b[38;5;245m suggestion\x1b[0m │','fix'),('│ ❯ \x1b[38;2;100;100;100msuggest\x1b[0m │','')]:
    r=subprocess.run(['primitives/tools/agent-messaging/agent-send','--guard-test'],input=json.dumps({'text':line}),text=True,capture_output=True,check=True)
    assert r.stdout.strip()==want,(line,r.stdout)
r=subprocess.run(['primitives/tools/agent-messaging/agent-send','--guard-test'],input='invalid',text=True,capture_output=True,check=True)
assert not r.stdout.strip()
print('PASS draft guard input fixtures')
hook='primitives/hooks/engine-host/scripts/engine-host'
for command in ('rex capture -s session:x -b block:x', 'rex --server unix:///missing capture', 'echo hello'):
    r=subprocess.run([hook,'hook','claude'],input=json.dumps({'tool_name':'Bash','tool_input':{'command':command}}),text=True,capture_output=True,check=True)
    if command.startswith('rex'):
        assert json.loads(r.stdout)['hookSpecificOutput']['permissionDecision']=='deny',r
    else: assert not r.stdout,r
r=subprocess.run([hook,'hook','claude'],input='invalid',text=True,capture_output=True,check=True)
assert not r.stdout,r
print('PASS capture refusal without pane/socket and allow on malformed hook input')
PY
