#!/usr/bin/env bash
# Syntax and pure input contracts for the retained Rex integration.
set -euo pipefail
cd "$(dirname "$0")/../.."
SCRIPTS=(primitives/hooks/rex-context/scripts/rex-context primitives/hooks/engine-host/scripts/engine-host
  primitives/tools/agent-messaging/agent-{send,spawn,read} primitives/tools/agent-messaging/seat
  primitives/tools/agent-messaging/relay/agent-{send,spawn}-hive
  rex/tests/run.sh)
for f in "${SCRIPTS[@]}"; do bash -n "$f"; done
printf 'PASS bash syntax\n'
if command -v shellcheck >/dev/null; then
  shellcheck "${SCRIPTS[@]}"
  printf 'PASS shellcheck\n'
else printf 'SKIP shellcheck (unavailable)\n'; fi
python3 - <<'PY'
import json, subprocess
from pathlib import Path
for name in ('agent-ask',):
    p=Path('primitives/tools/agent-messaging')/name
    compile(p.read_text(),str(p),'exec')
print('PASS Python syntax')
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

# Invalid invocations must fail before contacting a server or opening a pane.
python3 - <<'PYTEST'
import os, subprocess
spawn='primitives/tools/agent-messaging/agent-spawn'
for args, message in [([], 'usage:'), (['--detached'], 'detached agents are retired'),
                      (['--brief-file'], '--brief-file needs text')]:
    result=subprocess.run([spawn,*args],text=True,capture_output=True)
    assert result.returncode == 2, (args,result)
    assert message in result.stderr, (args,result.stderr)
env={k:v for k,v in os.environ.items() if not k.startswith(('AGENT_', 'REX_', 'LC_REX_'))}
result=subprocess.run([spawn,'session:test','name','--','codex'],env=env,text=True,capture_output=True)
assert result.returncode == 2 and "caller's own session and pane are required" in result.stderr,result
env.update(AGENT_SESSION='session:test', AGENT_PANE='block:test')
for args,message in [(['codex','extra'], 'agents take one profile'),
                     (['unknown'], 'unknown agent profile'),
                     (['codex'], 'agents require --brief-file')]:
    result=subprocess.run([spawn,'session:test','name','--',*args],env=env,text=True,capture_output=True)
    assert result.returncode == 2 and message in result.stderr,(args,result)
print('PASS spawn input refusal without server access')
PYTEST

# The wrapper forwards exact bytes through a fixed scoped destination and never falls through to Rex.
python3 - <<'PYCHANNEL'
import json, os, pathlib, subprocess, tempfile
sender=str(pathlib.Path('primitives/tools/agent-messaging/agent-send').resolve())
with tempfile.TemporaryDirectory() as d:
    root=pathlib.Path(d)
    tool=root/'teerex'
    tool.write_text('#!/usr/bin/python3\nimport json,sys\nfrom pathlib import Path\nPath('+repr(str(root/'request'))+').write_text(json.dumps(dict(argv=sys.argv[1:],body=sys.stdin.read())))\n')
    tool.chmod(0o700)
    env=dict(os.environ,PATH=d+os.pathsep+os.environ['PATH'],AGENT_CHANNEL=d+'/handle.json',AGENT_REPORT_TO='session:fixed block:fixed')
    body='ACK item-one β: quoted "text"\nlast line\n'
    r=subprocess.run([sender,'session:fixed','block:fixed','worker',body],env=env,text=True,capture_output=True)
    assert r.returncode==0,r.stderr
    req=json.loads((root/'request').read_text())
    assert req['body']==body
    args=req['argv']
    assert args[:2]==['agents','channel']
    assert args[args.index('--handle')+1]==d+'/handle.json'
    assert args[args.index('--to')+1]=='report-to'
    token=args[args.index('--request-id')+1]
    assert len(token)==32 and all(c in '0123456789abcdef' for c in token)
    env['AGENT_CHANNEL_DROP']='1'
    r=subprocess.run([sender,'session:fixed','block:fixed','worker',body],env=env,text=True,capture_output=True)
    assert r.returncode==0,r.stderr
    assert '--drop' in json.loads((root/'request').read_text())['argv']
    (root/'request').unlink()
    r=subprocess.run([sender,'session:other','block:other','worker',body],env=env,text=True,capture_output=True)
    assert r.returncode==2 and not (root/'request').exists()
print('PASS scoped send bytes, fresh request id and destination refusal')
PYCHANNEL
