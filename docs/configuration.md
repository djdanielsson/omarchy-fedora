# Configuration

## Build

`build_files/build.sh` runs inside the container build (`Containerfile` copies `system_files/` + `build_files/`).

- Enables the `agaspar/omedora-4` and `whelanh/omarchy` COPRs, RPM Fusion free/nonfree, and the Tailscale repo.
- Installs `build_files/packages-common.txt`, Warp repo, `mise`, `tzupdate`.
- Enables services: `sddm`, `NetworkManager`, `bluetooth`, `cups`, `thermald`, `tuned` + `tuned-ppd`, `firewalld`, `podman.socket`, `tailscaled`, `chronyd`, `fprintd`, `ModemManager`, `upower`, `fwupd-refresh.timer`, `omarchy-firstboot-flatpak`, per-user `omarchy-firstrun-github`.
- Tweaks: `xdg-terminal-exec` → `warp.desktop`; derives SDDM `omarchy` theme from maldives + Lumon wallpaper (02); patches QML for BT visibility + calendar size + network Send button + clock clicks + lock fingerprint check.

## First boot

- **Flatpak:** `omarchy-firstboot-flatpak.service` adds Flathub, installs Bitwarden/LocalSend/Firefox/Steam, applies LocalSend home override; retries until success, then touches a done-file.
- **Per-user:** `omarchy-firstrun-github.service` (global user unit) opens a floating terminal once to set `git user.name`/`email` + `gh auth` + offers `fprintd-enroll` (see [Fingerprint](fingerprint.md)).

## Auto timezone

`omarchy-tzupdate.service` + `.timer` (boot + 12h, persistent) plus NetworkManager dispatcher `99-omarchy-tzupdate` on full connectivity — `tzupdate` keeps `/etc/localtime` in sync when you travel.

## Bar & shell

Skeleton configs cover Hyprland (`~/.config/hypr/`) and the Omarchy shell (`~/.config/omarchy/shell.json`, media and mic widgets, Lumon default, 150s screensaver and 300s lock).

## Known image patches

All live in `build.sh` steps 7b–7g so they apply on top of real vendored QML rather than frozen-in-git copies.
