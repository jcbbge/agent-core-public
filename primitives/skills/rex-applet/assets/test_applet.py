"""Tests for an applet built from the rex-applet template. Run: python3 -m unittest discover tests

No live Rex and no live sources: frames come from --replay fixtures; the terminal loop runs in a private PTY.
"""
import fcntl
import json
import os
import pty
import select
import signal
import struct
import subprocess
import tempfile
import termios
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / os.environ.get('APPLET', 'applet')
FIXTURE = {'read_at': '12:00:00', 'host': 'hive', 'load': [0.5, 0.4, 0.3], 'disk': {'used': 50, 'total': 100}}


def replay_dir():
    d = tempfile.mkdtemp()
    Path(d, 'state.json').write_text(json.dumps(FIXTURE))
    return d


class Frames(unittest.TestCase):
    def frame(self, width, state=FIXTURE):
        d = tempfile.mkdtemp()
        Path(d, 'state.json').write_text(json.dumps(state))
        r = subprocess.run([str(APP), '--replay', d, '--once', '--width', str(width), '--height', '20'],
                           capture_output=True, text=True, timeout=10, check=True)
        return r.stdout.splitlines()

    def test_fits_every_width(self):
        for width in (20, 60, 72, 120):
            for line in self.frame(width):
                self.assertLessEqual(len(line), width, line)
                self.assertNotIn('\x1b', line)

    def test_unavailable_source_is_named(self):
        lines = self.frame(72, {**FIXTURE, 'load': 'unavailable: no loadavg'})
        self.assertTrue(any(l.startswith('✗') and 'load' in l for l in lines))


class Terminal(unittest.TestCase):
    def test_draws_redraws_and_restores(self):
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 72, 0, 0))
        original = termios.tcgetattr(slave)
        p = subprocess.Popen([str(APP), '--replay', replay_dir()], stdin=slave, stdout=slave, stderr=slave,
                             env={**os.environ, 'NO_COLOR': '1'})
        out = b''

        def until(marker):
            nonlocal out
            start, deadline = len(out), time.monotonic() + 5
            while marker not in out[start:] and time.monotonic() < deadline:
                if select.select([master], [], [], .1)[0]:
                    out += os.read(master, 65536)
            self.assertIn(marker, out[start:])
        try:
            until(b'\x1b[?2026l')
            self.assertIn(b'\x1b[?1049h', out)
            self.assertIn(b'\x1b]7501;state=done', out)
            os.write(master, b'?'); until(b'keys')
            fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 30, 120, 0, 0))
            p.send_signal(signal.SIGWINCH); until(b'\x1b[?2026l')
            os.write(master, b'q'); until(b'state=clear')
            self.assertEqual(p.wait(timeout=5), 0)
            self.assertIn(b'\x1b[?25h\x1b[?1049l', out)
            after = termios.tcgetattr(slave)
            pendin = getattr(termios, 'PENDIN', 0)  # macOS's kernel sets it on a mode change
            after[3] &= ~pendin; original[3] &= ~pendin
            self.assertEqual(after, original)
        finally:
            if p.poll() is None:
                p.kill(); p.wait()
            os.close(master); os.close(slave)


if __name__ == '__main__':
    unittest.main()
