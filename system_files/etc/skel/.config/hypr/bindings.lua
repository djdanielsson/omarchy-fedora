-- Personal bindings. Loaded after Omarchy-Fedora defaults (Warp-only).
-- Full Omarchy bindings reference: omacom/omarchy quattro default/hypr/bindings/.
-- Example: rebind terminal (not needed — Warp is already the default):
-- o.rebind("SUPER + Return", "Terminal", o.launch("warp-terminal"))
-- Example extra workspace:
-- o.bind("SUPER + 6", "Workspace 6", hl.dsp.workspace("6"))

-- App launcher alias (2026-09-12 fix): SUPER+D opens the Omarchy apps menu,
-- same as SUPER+ALT+SPACE. Native quickshell menu is primary; rofi/wofi/fuzzel
-- remain installed as fallback (e.g. `rofi -show drun` when the shell is down).
o.bind("SUPER + D", "Apps menu", "omarchy-menu toggle apps")
