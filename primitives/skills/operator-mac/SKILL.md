---
name: operator-mac
description: From a remote server the operator reaches over SSH, drive a browser on the operator's Mac and put text on the Mac's clipboard. Use when working on the server and the operator needs to see or verify a web UI, take screenshots, or copy text from the server ("show me in my browser", "open it on my Mac", "copy that to my clipboard", "I can't copy from the VPS"). Not for a browser on the server itself.
---

# operator-mac — the operator's browser and clipboard, from the server

The operator sits at a Mac and works on this server over SSH. A long-lived SSH connection from
the Mac carries ports both ways, so nothing here opens a tunnel.

| Direction | What it carries | On the server |
|---|---|---|
| Mac → server | the Mac's `localhost:<port>` reaches the server's `127.0.0.1:<port>` | the operator opens `http://localhost:<port>/` in their own browser |
| server → Mac | a dedicated Chrome on the Mac, remote-controlled over CDP | `http://127.0.0.1:9222` |
| server → Mac | the terminal clipboard (OSC 52) | `clip` |

## Check first

```sh
curl -s -m 3 http://127.0.0.1:9222/json/version   # JSON = the Mac's browser is reachable
command -v clip                                   # present = clipboard helper installed
```

If no JSON comes back, the dedicated Chrome isn't running. Ask the operator to run `hive-chrome` on
the Mac; it does nothing if Chrome is already up. Never point CDP at the operator's everyday
Chrome: it holds their logins.

## Show the operator a web UI on the server

1. Bind the server to `127.0.0.1:<port>`, never `0.0.0.0`.
2. If `<port>` is not already forwarded (4747 is), the forward is added on the Mac as a
   `LocalForward` on the always-on connection. Never hand the operator an `ssh -L` command.
3. Give them `http://localhost:<port>/`. A process started inside your own session dies with
   it; anything they will keep opening needs a supervised service.

## Drive the browser

`scripts/cdp.mjs` connects to the Mac's Chrome, opens a fresh tab, runs the JavaScript on stdin
with `browser`, `context` and `page` in scope (full Playwright Page API), then closes the tab.

```sh
node scripts/cdp.mjs <<'EOF'
await page.goto("http://localhost:4747/");
console.log(await page.title());
await page.screenshot({ path: "/tmp/shot.png" });   // the file lands on the server
EOF
```

- `URL`s in the script resolve **on the Mac**. A server port is reachable from the browser only
  if it is forwarded (see above).
- `KEEP=1` leaves the tab open so the operator can see it and keep using it.
- `CDP_URL` overrides the endpoint.
- Never close tabs you did not open.

The `dev-browser` CLI's Linux binary may not run on older distributions (GLIBC). If it does run,
`dev-browser --connect http://127.0.0.1:9222` is equivalent.

## Copy to the operator's clipboard

```sh
git log -1 --format=%H | clip
clip "text to copy"
```

`clip` is `scripts/clip`, linked onto PATH. It writes OSC 52: inside tmux through
`tmux load-buffer -w` (requires `set-clipboard on`), otherwise straight to the terminal. The
operator's terminal must allow clipboard writes. It reaches only the terminal you are attached
to, so it does nothing from a detached or background process. In that case, write the text to a
file and give the operator its path.

## Done when

- The browser: your script printed something read back from the page, such as a title or a
  selector's text, not just "no error."
- The clipboard: the operator pasted it. You cannot see the Mac's clipboard from the server.
