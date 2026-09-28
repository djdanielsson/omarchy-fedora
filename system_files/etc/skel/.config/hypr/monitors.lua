-- Personal monitor overrides. Loaded after Omarchy-Fedora defaults.
-- Example (keys are output/mode/position/scale):
-- hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- ThinkPad panel default: pin 1x. Without this Hyprland auto-picks 1.5 on
-- the 157dpi eDP display at every login. Only matches laptop panels.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
