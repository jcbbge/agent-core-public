# Rex's model: servers, blocks, clients

Sources: Rex's docs (`superlogical.com/rex/docs/llms-full.txt`), the Rex Beta Discord feedback forums
through the community MCP (`claude mcp add -s user --transport http superlogical
https://www.superlogical.com/rex/community-mcp`; it needs a Discord sign-in), and the Rex server binary,
read 2026-11-24 (server 0.1.0-preview.21/22). Re-check against the docs and the forums before relying on
anything marked planned or unpublished.

## The pieces

| Piece | What it is |
|---|---|
| **Server** | Holds sessions, tabs and blocks and keeps their programs running whether or not anyone is watching. Has no screen. Hive runs one headless (`rex.service`); the Mac app has one built in. |
| **Block** | One thing a server holds in a session: state, methods, events, an optional data stream. Its kind (flavor) comes from a creator: today terminal, tunnel dial/listen, onboarding (`rex api call block_creator.list`). |
| **Client** | Anything connected to a server to show or drive it: the Mac and iOS apps, the `rex` command, a Lua script, an SDK program (the work engine's bridge). Holds nothing; blocks outlive it. |

- A client is never a block and a block is never a client. A program inside a terminal block can act
  as a client (an agent running `rex`).
- Many to many: one server, many blocks; one block shown by several clients at once; one client
  connected to several servers (the Mac app: its own server plus hive's).
- A new block kind must come from the server; clients draw it. Overlay tools (rexweb) paint over a
  terminal block and the server never knows.

## Servers never talk to each other

Every connection is client to server. One server reaches another only through a client connected to
both: `client.action` carries `servers` (other servers this client is connected to) and `server` (the one
holding the target block), and a config action calls them with `rex.server(label)`. Scripts reach the
hosts `rex hosts` lists. Remote access is SSH (`ssh://user@host`, recommended; runs Rex's connector on the
far end), built-in Tailscale, Tailscale Serve, or plain HTTP with `--allow-anonymous`.

Josh's direction rule (2026-11-24): the Mac may reach hive; hive never connects to, calls or reads the
Mac's built-in server.

## Actions live in the client's config

Superlogical, Discord, 2026-10-20: actions and key bindings are defined and run in the client: "You can
define them in the local init.lua and they still act on remote sessions." A remote server's own
`rex.action`s do not appear in a remote app's palette and its bindings do nothing there (deferred as a
docs issue). `rex do NAME` against that server still works. So a palette action that must work in every
block, on every host, belongs in the app's (client's) config; keep that file minimal and sourced from
rexconfig.

Hosts sync one way, app to server: hosts added with `rex hosts add` do not appear in the Mac app
(deferred, several reports).

## Block plugins: present, unpublished

- `rex server run --block-dir DIR` "discovers executable block plugins"; `--block-plugin-reload` reloads
  them after source changes. The docs say nothing more.
- The binary shows a full loader (`blockplugin.discover`, `Load`, `bind`, `watchReload`, advertised
  creators, a control channel, process supervision) and Superlogical's own blocks built on an internal Go
  kit, `go.superlogical.com/rex/sdk/block` (not public; the import path redirects to the homepage).
- Asked publicly on 2026-11-05 whether the protocol will go public and whether clients will render
  custom data; no team answer recorded. Whether the Mac app draws an unknown flavor is unknown.
- Any plugin built now is against an unpublished, changing protocol: run it on a separate, disposable
  Rex server, never by restarting the live one.

## Planned, per the team

- Browser and file-browser block types: "Planned but not short term" (2026-10-23).
- Program status grows into push notifications and a priority inbox (docs). Josh does not want either:
  leave them off.

## Browser in a pane today

terminal-browser (MIT, `zenbu-labs/terminal-browser`) renders Chromium into a terminal block with kitty
graphics, so it works in a session on a remote server and on iOS; `terminal-browser action` lets an agent
drive it. Installed on hive 2026-11-24 with setup skipped and telemetry off; needs `libgtk-3-0` on Linux.
It is a tool, not the app layer: nothing drives work from it.
