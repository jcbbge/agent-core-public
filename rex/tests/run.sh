#!/usr/bin/env bash
# Check syntax and locally testable behavior without contacting either Rex server.
set -euo pipefail
cd "$(dirname "$0")/../.."
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
export PYTHONPYCACHEPREFIX="$TEST_DIR/pycache"
SCRIPTS=(rex/bin/rex rex/bin/rex-hive-sync primitives/hooks/rex-context/scripts/rex-context primitives/tools/agent-messaging/agent-{send,spawn,launch,seat} primitives/tools/agent-messaging/relay/agent-{send,spawn}-hive rex/tests/run.sh)
for f in "${SCRIPTS[@]}"; do bash -n "$f"; done
printf 'PASS bash syntax\n'
if command -v shellcheck >/dev/null; then shellcheck "${SCRIPTS[@]}"; printf 'PASS shellcheck\n'; else printf 'SKIP shellcheck (unavailable)\n'; fi
python3 -m py_compile rex/bin/rex-flight rex/bin/rex-hive-actions primitives/tools/agent-messaging/agent-inbox
printf 'PASS Python syntax\n'
if command -v luac >/dev/null; then
  luac -p rex/init.lua rex/watch.lua
  printf 'PASS Lua syntax (luac)\n'
elif python3 -c 'import lupa' 2>/dev/null; then
  python3 - <<'PY'
from lupa import LuaRuntime
from pathlib import Path
for f in ('rex/init.lua','rex/watch.lua'): LuaRuntime().compile(Path(f).read_text())
PY
  printf 'PASS Lua syntax (lupa)\n'
else
  printf "SKIP lua syntax (no luac): the seat's rex config check covers init.lua\n"
fi
python3 - <<'PY'
import json, os, pty, select, subprocess, tempfile, time
from pathlib import Path
root=Path.cwd(); tools=root/'primitives/tools/agent-messaging'
with tempfile.TemporaryDirectory() as tmp:
    tmp=Path(tmp); home=tmp/'home';home.mkdir(); bins=tmp/'bin';bins.mkdir()
    env=dict(os.environ,HOME=str(home),PATH=str(bins)+':'+os.environ['PATH'],XDG_STATE_HOME=str(tmp/'state'))
    for key in ('REX_SESSION','REX_BLOCK','AGENT_PANE','AGENT_SESSION','RV_RELAY_MAILBOX','AGENT_INBOX_DIR'): env.pop(key,None)
    def stub(name,body):
        f=bins/name;f.write_text('#!/bin/bash\n'+body+'\n');f.chmod(0o755)
    def run(path,*args,input='',extra=None):
        return subprocess.run([str(path),*args],input=input,text=True,capture_output=True,env=dict(env,**(extra or {})),timeout=10)
    stub('rex',"echo '{}'")
    context=root/'primitives/hooks/rex-context/scripts/rex-context'
    r=run(context,extra={'XDG_CACHE_HOME':str(tmp/'cache')});assert r.returncode==0 and len(r.stdout.splitlines())==6,r
    empty=tmp/'empty';empty.mkdir()
    r=subprocess.run(['/bin/bash',str(context)],capture_output=True,env=dict(env,PATH=str(empty)));assert r.returncode==0 and not r.stdout,r
    print('PASS context with and without Rex')
    for line,want in [('│ ❯ │',''),('│ ❯ \x1b[2msuggest\x1b[0m │',''),('│ ❯ \x1b[90msuggest\x1b[0m │',''),('│ ❯ fix the tests │','fix the tests'),('│ ❯ fix\x1b[38;5;245m suggestion\x1b[0m │','fix'),('│ ❯ \x1b[38;2;100;100;100msuggest\x1b[0m │','')]:
        r=run(tools/'agent-send','--guard-test',input=json.dumps({'text':line}));assert r.returncode==0 and r.stdout.strip()==want,(line,r)
    assert not run(tools/'agent-send','--guard-test',input='invalid').stdout
    print('PASS typing guard fixtures and malformed input')
    stub('rex', '''echo '[{"block_id":"block:a","label":"worker"}]' ''')
    def event(kind,payload): return {'type':'session_event','payload':{'session_id':'session:s','event':{'type':kind,'payload':payload}}}
    # Both CLI examples from docs/reference__events.md, with the fixture's block id.
    events=[{'type':'session_created','payload':{'session':{'session_id':'session:01a1...','label':'work'}}},event('block_created',{'block_id':'block:a'})]
    for sub in ('','child'):
        events.append(event('block_event',{'block_id':'block:a','creator_name':'com.superlogical.terminal','name':'program_status_changed','payload':{'id':sub,'record':{'state':'blocked','kind':'question','app':'claude-code','msg':'V2FpdGluZw=='},'reason':'update'}}))
    events.extend([event('block_event',{'block_id':'block:a','creator_name':'com.superlogical.terminal','name':'child_exited','payload':{'exit_code':2,'error':'exit status 2'}}),event('block_closed',{'block_id':'block:a'})])
    r=run(root/'rex/bin/rex-flight','record','--stdin',input='\n'.join(map(json.dumps,events)));assert r.returncode==0,r
    records=[json.loads(l) for f in (tmp/'state/rex-flight').glob('*.jsonl') for l in f.read_text().splitlines()]
    assert len(records)==5 and records[1]['msg']=='Waiting' and 'sub' not in records[1] and records[2]['sub']=='child' and records[3]['exit_code']==2,records
    r=run(root/'rex/bin/rex-flight','show','worker','-n','20');assert len(r.stdout.splitlines())==5 and 'Waiting' in r.stdout,r
    print('PASS flight filtering, labels, decoded messages, root/child status and show')
    config=home/'.config/hive';config.mkdir(parents=True);generator=root/'rex/bin/rex-hive-actions'
    for line in ('work\techo hi','work = echo hi','work: echo hi','work) echo hi ;;'):
        (config/'launch').write_text('# comment\n'+line+'\n');r=run(generator);assert r.returncode==0 and 'hive_work' in r.stdout,r
    (config/'launch').write_text('work = echo hi\nunparsed shell stuff');r=run(generator);assert r.returncode==2 and not r.stdout and 'unparsed' in r.stderr,r
    (config/'actions.tsv').write_text('work\tSay "hi" \\ again\techo hi\n');r=run(generator);assert r.returncode==0 and '\\"hi\\"' in r.stdout and '\\\\ again' in r.stdout,r
    print('PASS launch menu formats, atomic failure and Lua escaping')
    stub('ssh','printf \'%s\\n\' "$@"')
    r=run(root/'rex/bin/rex','ls');assert r.returncode==0 and 'm5' in r.stdout and 'Rex' in r.stdout,r
    for name in ('send','spawn'):
        args=('session:s','block:a','sender','hello') if name=='send' else ('session:s','worker','--','true')
        r=run(tools/f'relay/agent-{name}-hive',*args);assert r.returncode==0 and 'm5' in r.stdout and f'agent-{name}' in r.stdout,r
    print('PASS Mac shim and relay forwarding')
    local=home/'.local/bin';local.mkdir(parents=True)
    spawn=local/'agent-spawn';spawn.write_text('#!/bin/bash\nprintf \'%s\\n\' "$@"\n');spawn.chmod(0o755)
    brief='A brief with "quotes", $vars, and `commands`\nsecond line'
    r=run(tools/'agent-launch','session:s','block:seat','launch-test',input=brief)
    saved=list((home/'.local/state/agent-briefs').glob('*.md'))
    assert r.returncode==0 and len(saved)==1 and saved[0].read_text().endswith(brief),r
    expected='exec ~/.local/bin/claude --dangerously-skip-permissions "$(cat ~/'+str(saved[0].relative_to(home))+')"'
    assert r.stdout.splitlines()==['session:s','launch-test','--','sh','-c',expected],r
    stub('uname','echo Darwin');stub('ssh','cat > "$HOME/remote-brief"')
    r=run(tools/'agent-launch','session:s','block:seat','mac-test',input=brief)
    assert r.returncode==0 and (home/'remote-brief').read_text().endswith(brief) and 'exec ssh -t hive "export AGENT_SESSION=$AGENT_SESSION' in r.stdout and '\\$(cat ~/' in r.stdout,r
    assert run(tools/'agent-launch','s','p','INVALID',input='bad').returncode==2
    print('PASS native and Mac launch brief transport, command quoting, bad-name refusal')
    inbox=tmp/'inbox';inbox.mkdir()
    decision={'id':'test','title':'Test','ask':'Proceed?','context':'Test','options':[],'recommend':'Proceed'}
    (inbox/'seat.log').write_text(json.dumps({'at':'2026-11-11T12:00:00Z','from':'test','msg':'DECISION-JSON:'+json.dumps(decision)})+'\n')
    master,slave=pty.openpty();proc=subprocess.Popen([str(tools/'agent-inbox'),'seat'],stdout=slave,stderr=slave,env=dict(env,AGENT_INBOX_DIR=str(inbox)));os.close(slave)
    data=b'';deadline=time.monotonic()+4
    try:
        while b'1 waiting\x07' not in data and time.monotonic()<deadline:
            if select.select([master],[],[],0.2)[0]: data+=os.read(master,65536)
        assert b'\x1b]2;Inbox ' in data and b'1 waiting\x07' in data,data
    finally: proc.terminate();proc.wait();os.close(master)
    print('PASS inbox decision count title in a PTY')
PY
