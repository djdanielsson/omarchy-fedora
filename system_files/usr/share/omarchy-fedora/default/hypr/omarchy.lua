-- Omarchy-Fedora Hyprland defaults loader (Lua).
-- Mirrors Omarchy default/hypr/omarchy.lua: helpers, envs, looknfeel, input,
-- window rules, full bindings, autostart, theme overrides.

require("default.hypr.helpers")
local require_optional = require("default.hypr.require_optional")

-- Core defaults (order matters: envs before input; windows after looknfeel).
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.input")
require("default.hypr.windows")
require("default.hypr.bindings.tiling")
require("default.hypr.bindings.applications")
require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.utilities")
require("default.hypr.autostart")

-- Current theme overrides (theme-set writes omarchy.current.theme.hyprland).
require_optional.module("omarchy.current.theme.hyprland")
