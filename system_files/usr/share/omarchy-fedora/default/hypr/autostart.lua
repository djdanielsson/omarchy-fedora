-- Autostart: Fedora-adapted port of Omarchy default/hypr/autostart.lua (MIT).
-- Omarchy shell/ is vendored (system_files/usr/share/omarchy-fedora/shell)
-- and owns bar, notifications, menus, and lock — so no mako/waybar/Caelestia
-- here. Arch-only provisioners (provision-first-run, powerprofiles-init,
-- monitor-watch, post-boot hooks) have no Fedora equivalent yet.

hl.on("hyprland.start", function()
  -- Slow app launch fix -- set systemd vars before starting session services.
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Secrets / mounts / polkit (no GUI prompts work without these).
  hl.exec_cmd("/usr/libexec/mate-polkit || mate-polkit &")
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh,gpg")
  hl.exec_cmd("udiskie --automount --notify &")

  -- XDG user dirs (~/Downloads, ~/Documents, ...). Hyprland doesn't
  -- process /etc/xdg/autostart, so the GNOME-provided xdg-user-dirs entry
  -- never runs here — without this, XDG_DOWNLOAD_DIR falls back to $HOME,
  -- which the Firefox flatpak sandbox denies (!home), breaking all
  -- downloads (2026-10-04). Idempotent: only creates what's missing.
  hl.exec_cmd("xdg-user-dirs-update &")

  -- Omarchy shell (bar, panels, menus, notifications, lock). Supervised and
  -- journal-logged; use omarchy-restart-shell to restart it by hand.
  hl.exec_cmd("omarchy-launch-shell")

  -- Clipboard history.
  hl.exec_cmd("wl-paste --watch cliphist store &")

  -- Idle lock via the shell's lock service (swaylock stays as fallback).
  hl.exec_cmd("swayidle -w timeout 300 'omarchy-system-lock' before-sleep 'omarchy-system-lock' &")
end)
