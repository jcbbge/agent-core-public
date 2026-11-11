-- Rex's always-on watcher: fleet placement, rising inbox layers and subtle state tints.
-- Run: rex do ~/.config/rex/watch.lua --all. It never emits notifications.
local T = "com.superlogical.terminal"
local STATE = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local TINT = { blocked = "#231c0e", error = "#24110f", done = "#0f1f15" }
local tinted, counts, revisions, labels = {}, {}, {}, {}
local function root(ev) return (ev.id == nil or ev.id == "") and ev.record end -- CHECK: rex events -s <session> --json (C7)
local function anchor_path(bid) return STATE .. "/rex-fleet/" .. bid:match("[^:]+$") .. ".anchor" end
local function fleet_anchor(bid)
  local f = io.open(anchor_path(bid))
  if not f then return nil end
  local a = f:read("*l"); f:close()
  return (a and a ~= "") and a or false
end
local function view(sid)
  return rex.call("session.view", { session_id = sid }) or {} -- CHECK: rex api describe session.view --json (C4)
end
local function focused(v)
  for _, w in ipairs(v.windows or {}) do
    if w.window_id == v.active_window_id then return w.focused_block_id end
  end
end
local function blocks(sid)
  local list = (rex.call("session.list_blocks", { session_id = sid }) or {}).blocks or {} -- CHECK: rex api describe session.list_blocks --json (C5)
  for _, b in ipairs(list) do labels[b.block_id] = b.label end
  return list
end
local function placement(sid, bid)
  for _, b in ipairs(blocks(sid)) do if b.block_id == bid then return b.placement end end
end
local function label(sid, bid)
  if labels[bid] == nil then blocks(sid) end
  return labels[bid]
end
local function tint(sid, bid, state)
  local args = TINT[state] and { background = TINT[state] } or {} -- CHECK: rex api describe com.superlogical.terminal.set_theme --json (C8)
  local _, err = rex.block.call(T, "set_theme", { session_id = sid, block_id = bid, args = args }) -- CHECK: C8 args nesting
  if err then error(err, 0) end
  tinted[bid] = TINT[state] and state or nil
end
local function holds(n, bid)
  if not n then return false end
  if n.block then return n.block.block_id == bid end
  return n.split and (holds(n.split.before, bid) or holds(n.split.after, bid)) or false
end
local function on(name, fn)
  rex.on(name, function(ctx, ev)
    local ok, err = pcall(fn, ctx, ev)
    if not ok then rex.log("warn", name .. ": " .. tostring(err)) end
  end)
end
on("terminal.program_status_changed", function(ctx, ev)
  local r = root(ev)
  if not r then return end
  local sid, bid = ctx.session_id, ctx.block_id
  if label(sid, bid) ~= "inbox" then
    if TINT[r.state] then tint(sid, bid, r.state)
    elseif r.state == "working" or r.state == "idle" then tint(sid, bid, nil) end
  end
  local a = fleet_anchor(bid)
  if a == nil then return end
  local placed = placement(sid, bid)
  if TINT[r.state] and placed == "detached" then
    local target = a and placement(sid, a) == "placed" and a or focused(view(sid))
    local _, err = rex.session.move_block{ session_id = sid, block_id = bid, anchor_block_id = target,
      direction = "vertical", side = "after", ratio = 0.6 }
    if err then error(err, 0) end
  elseif r.state == "working" and placed == "placed" and focused(view(sid)) ~= bid then
    local _, err = rex.session.detach_block{ session_id = sid, block_id = bid }
    if err then error(err, 0) end
  end
end)
on("terminal.program_status_removed", function(ctx, ev)
  for _, id in ipairs(ev.ids or {}) do
    if id == "" and label(ctx.session_id, ctx.block_id) ~= "inbox" then tint(ctx.session_id, ctx.block_id, nil) end
  end
end)
on("block_closed", function(ctx, ev)
  local bid = ev.block_id or ctx.block_id
  os.remove(anchor_path(bid)); tinted[bid] = nil; labels[bid] = nil; counts[bid] = nil
end)
on("terminal.title_changed", function(ctx, ev)
  local sid, bid = ctx.session_id, ctx.block_id
  if label(sid, bid) ~= "inbox" then return end
  local n = tonumber((ev.title or ""):match("(%d+) waiting"))
  if not n then return end
  local old = counts[bid] or 0; counts[bid] = n
  if n <= old then return end
  for _, w in ipairs(view(sid).windows or {}) do
    for _, l in ipairs(w.layers or {}) do
      if holds(l.layout, bid) and l.state == "minimized" then
        local _, err = rex.session.set_layer_state{ session_id = sid, layer_id = l.layer_id, state = "normal" }
        if err then error(err, 0) end
        local _, raise_err = rex.session.raise_layer{ session_id = sid, layer_id = l.layer_id }
        if raise_err then error(raise_err, 0) end
      end
    end
  end
end)
on("session_view_changed", function(ctx, ev)
  local sid = ctx.session_id
  if not ev.revision or ev.revision <= (revisions[sid] or -1) then return end
  revisions[sid] = ev.revision
  local bid = focused(view(sid))
  if bid and tinted[bid] == "done" then tint(sid, bid, nil) end
end)
