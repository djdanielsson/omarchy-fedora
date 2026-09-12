-- Essential application bindings (Fedora core set).
-- Omarchy upstream also binds preinstalled apps, TUIs, and web apps here;
-- dropped per spec (no Spotify/Docker-TUI/Signal/Obsidian/webapps/1Password —
-- Bitwarden flatpak instead). Warp-only terminal per owner choice.

o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + SHIFT + RETURN", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { omarchy = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

-- Bitwarden (flatpak) quick open.
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "flatpak run com.bitwarden.desktop" })
