-- Personal look-and-feel overrides. Loaded after Omarchy-Fedora defaults.
-- Theme overrides land in ~/.local/state/omarchy/current/theme/hyprland.lua
-- once the Lumon theme port lands; put manual tweaks here.
-- Example:
-- hl.config({ general = { gaps_in = 4, gaps_out = 8 } })

-- Portal file pickers (Save/Open) open huge on 1080p. Pin them centered
-- and usable (2026-09-12).
o.window("xdg-desktop-portal-gtk", { float = true })
o.window("xdg-desktop-portal-gtk", { center = true })
o.window("xdg-desktop-portal-gtk", { size = { 900, 620 } })
