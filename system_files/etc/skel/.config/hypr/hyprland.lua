-- Omarchy-Fedora user config (Lua). Hyprland >= 0.55 loads hyprland.lua
-- INSTEAD of hyprland.conf (checked once at startup); hyprlang is deprecated
-- and gets no new features. Learn more: https://wiki.hypr.land/Configuring/Start/

-- Omarchy-Fedora bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy-fedora") .. "/default/hypr/bootstrap.lua")

-- Load Omarchy-Fedora defaults (envs, looknfeel, input incl. T14s TrackPoint,
-- Warp/Firefox bindings, autostart). Package updates can improve defaults
-- without rewriting your ~/.config/hypr files.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after the
-- defaults. Missing files are skipped silently.
local require_optional = require("default.hypr.require_optional")
require_optional.module("hypr.monitors")
require_optional.module("hypr.input")
require_optional.module("hypr.bindings")
require_optional.module("hypr.looknfeel")
require_optional.module("hypr.autostart")

-- Toggle config flags dynamically (e.g. theme toggles in ~/.local/state).
require_optional.module("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- hl.device({ name = "my-mouse", sensitivity = -0.5 })
