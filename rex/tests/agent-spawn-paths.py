#!/usr/bin/env python3
"""Only agent-spawn: command-host paths, exact brief bytes and cleanup."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

SCRIPT = Path(os.environ['SPAWN_SCRIPT']) if 'SPAWN_SCRIPT' in os.environ else Path(__file__).resolve().parents[2] / 'primitives/tools/agent-messaging/agent-spawn'
with tempfile.TemporaryDirectory() as tmp:
    root = Path(tmp).resolve()
    remote = root / 'command home'
    remote.mkdir()
    brief = root / 'caller brief'
    brief.write_text('reply OK and stop\n')
    tool = root / 'teerex'
    tool.write_text('''#!/usr/bin/env python3
import json, os, subprocess, sys
from pathlib import Path
a=sys.argv[1:]
if a[:2]==['targets','resolve']:
 print(json.dumps({'host':{'transport':os.environ['TRANSPORT'],'home':os.environ['REMOTE'],'address':'fixture','port':22,'identity_file':'/fixture/key','known_hosts':'/fixture/known_hosts'}}))
elif a[:2]==['targets','exec']:
 cmd=a[a.index('--')+1:]
 if cmd[:2]==['sh','-c'] and 'if [ -d' in cmd[2] and os.environ['CWD_EXISTS']=='0':
  print(os.environ['REMOTE'])
 else: sys.exit(subprocess.call(cmd))
elif 'resolve' in a:
 print(json.dumps({'resolved':{'session_id':'session:test'}}))
else:
 a=a[a.index('launch')+1:]
 def value(k): return a[a.index(k)+1]
 b=Path(value('--brief-file'))
 Path(os.environ['RECEIPT']).write_text(json.dumps({'cwd':value('--cwd'),'profiles':value('--config'),'brief':str(b),'bytes':b.read_text(),'mode':b.stat().st_mode & 0o777}))
 print(json.dumps({'target':{'block_id':'block:test'}}))
 sys.exit(int(os.environ.get('LAUNCH_STATUS','0')))
''')
    tool.chmod(0o755)
    ssh = root / 'ssh'
    ssh.write_text("#!/usr/bin/env python3\nimport os, shlex, subprocess, sys\ncmd=shlex.split(sys.argv[-1])\nif cmd[:2]==['sh','-c'] and 'if [ -d' in cmd[2] and os.environ['CWD_EXISTS']=='0':\n print(os.environ['REMOTE'])\nelse: sys.exit(subprocess.call(cmd))\n")
    ssh.chmod(0o755)
    for transport, exists, explicit, status in [('local', False, False, 0), ('ssh', False, False, 0), ('ssh', True, True, 0), ('ssh', False, False, 1)]:
        receipt = root / 'receipt'
        env = dict(os.environ, PATH=str(root)+os.pathsep+os.environ['PATH'], AGENT_SESSION='session:test', AGENT_PANE='block:test', TRANSPORT=transport, REMOTE=str(remote), RECEIPT=str(receipt), LAUNCH_STATUS=str(status), CWD_EXISTS=str(int(exists)))
        env.pop('TEEREX_PROFILES', None)
        if explicit: env['TEEREX_PROFILES']='/explicit/profiles.json'
        # The transport fixture controls whether the command host has this cwd.
        cwd = root
        result = subprocess.run([str(SCRIPT),'--brief-file',str(brief),'session:test','check','--','claude'],cwd=cwd,env=env,capture_output=True,text=True)
        assert result.returncode == status, result.stderr
        got = json.loads(receipt.read_text())
        assert got['bytes'] == brief.read_text()
        assert got['cwd'] == str(remote if transport == 'ssh' and not exists else root), got
        assert got['profiles'] == ('/explicit/profiles.json' if explicit else str(remote / '.config/teerex/profiles.json') if transport == 'ssh' else str(Path.home() / '.config/teerex/profiles.json')), got
        if transport == 'ssh':
            assert got['mode'] == 0o600, got
            assert not Path(got['brief']).exists(), got
        else:
            assert got['brief'] == str(brief), got
    print('PASS agent-spawn local/remote paths, profile override, private brief bytes and cleanup after success/failure')
