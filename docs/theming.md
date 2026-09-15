# Theming

- **Default:** `Lumon` + `Lumon Tux` (electric-cyan `#46d4f2` accent, amber secondary, near-black grounds) under `system_files/usr/share/omarchy-fedora/themes/`.
- **Wallpapers:** under each theme's `backgrounds/` (note: every Lumon wallpaper is `.webp` → `qt6-qtimageformats` is required; without it desktop and lock fall back to a flat color).
- **Apply:** `omarchy-theme-set <name>` and `omarchy-theme-bg-set <path>`; SDDM theme is derived at build from maldives + Lumon wallpaper.
- **Lock:** follows the desktop wallpaper, blurred.

## gum / templates

`gum` is installed for `gum_env.lua`-style template flows; the floating-terminal presentation wrapper currently just runs the command in a floating TUI.
