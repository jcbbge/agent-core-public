import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const script = fileURLToPath(new URL('./task', import.meta.url));
async function ledger(t, initial) {
  const dir = await mkdtemp(join(tmpdir(), 'task-ledger-'));
  t.after(() => rm(dir, { recursive: true, force: true }));
  const file = join(dir, 'TASKS.md');
  if (initial !== undefined) await writeFile(file, initial);
  return { read: () => readFile(file, 'utf8'), task: (...args) => execFileSync(script, args, {
    encoding: 'utf8', env: { ...process.env, TASKS_FILE: file, XDG_CONFIG_HOME: dir }
  }) };
}

test('done retains NOW and LATER text with UTC ISO timestamps and stable IDs', async t => {
  const l = await ledger(t);
  assert.match(l.task('list'), /done 0 \/ planned 0/);
  l.task('now', 'x'); l.task('later', 'y', '@tomorrow');
  assert.match(l.task('list'), /done 0 \/ planned 2/);
  l.task('done', '1', '#2');
  const text = await l.read();
  // Both open items left their sections (nothing but blank lines between headings) and DONE comes last.
  assert.match(text, /## NOW\n+## LATER\n+## DONE\n/);
  assert.match(text, /- \[x\] #1 x \(done \d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ\)/);
  assert.match(text, /- \[x\] #2 @tomorrow y \(done \d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ\)/);
  assert.match(l.task('list'), /done 2 \/ planned 2/);
  assert.match(l.task('now', 'next'), /#3 added/);
  assert.match(await l.read(), /- \[x\] #1 x/);
  assert.match(l.task('list'), /done 2 \/ planned 3/);
});

test('old ledgers acquire DONE and every existing mutator retains it', async t => {
  const l = await ledger(t, '# Tasks\n\n## NOW\n\n- [ ] #4 Legacy\n\n## LATER\n');
  l.task('done', '4');
  const done = (await l.read()).split('## DONE')[1];
  l.task('now', 'new'); l.task('defer', '5', '@soon'); l.task('promote', '5');
  l.task('later', 'dropped'); l.task('drop', '6');
  assert.equal((await l.read()).split('## DONE')[1], done);
  assert.match(l.task('list'), /done 1 \/ planned 2/);
  assert.match(l.task('now', 'no reused IDs'), /#7 added/);
});
