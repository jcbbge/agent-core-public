-- Rex config. Nothing hand-built lives here (Josh, 2026-11-13: "I do not want any fucking thing hand
-- rolled"): agents, inboxes, fleet and palettes come from Rex and teerex. Only the leaf plugin, as
-- `leaf rex install` writes it, with $HOME paths so the same file serves the M5 and hive.
local HOME = os.getenv("HOME")

-- >>> leaf >>>
-- Managed by `leaf rex install`; `leaf rex uninstall` removes it.
-- plugin: a55ea9689b312a41
local leaf_plugin = HOME .. "/.config/rex/plugins/leaf/init.lua"
local f = io.open(leaf_plugin)
if f then f:close(); dofile(leaf_plugin).setup({ bin = { HOME .. "/.cargo/bin/leaf" } }) end
-- open: document
-- <<< leaf <<<
