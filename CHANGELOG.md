# Changelog

All notable changes to this image. Dates are UTC. The live system on the T14s is the reference for "verified".

## [Unreleased]

### Changed
- Firefox now ships as Flathub `org.mozilla.firefox` (Downloads-only sandbox) instead of the Fedora RPM.

## 2026-09-12

### Fixed — round 8 — lumon-tux theme, dark default, wifi send button
- New theme `usr/share/omarchy-fedora/themes/lumon-tux/` (electric-cyan `#46d4f2` accent, amber secondary, near-black grounds, cyan Hyprland borders) matched to the Tux-glow wallpaper in its `backgrounds/`.
- Dark default: `etc/dconf/db/local.d/00-darkmode` (Adwaita-dark + prefer-dark) + `dconf update` in build. Live system already reported dark.
- Wi-Fi panel Send button + menu QR/Send entries committed; LocalSend firstboot override generalized to `--filesystem=home`.

### Fixed — portal pickers
- File choosers opened fullscreen-ish on 1080p. Pinned `xdg-desktop-portal-gtk` to centered 900×620 (live looknfeel + skel).

### Fixed — round 7 — wifi QR, speedtests, LocalSend
- **Wi-Fi QR + password:** ported `omarchy-network-qr` / `omarchy-network-password` (nmcli secrets + qrencode). Live matrix generates for the active wifi. Opening QR while on ethernet-only correctly reports no shareable Wi-Fi.
- **Speedtests:** ported `omarchy-network-speedtest` (fast.com curl phases) and `omarchy-disk-speedtest` (direct-I/O workers). Live: ~70 Mbps down, NVMe ~1650/1000 MB/s.
- **LocalSend:** Flathub `org.localsend.localsend_app` added to first-boot installs; firewall 53317/tcp+udp opened in image.
- **Network menu:** added `setup.network.qr` (summons wifiqr panel) and `setup.network.send` (launches LocalSend).
- **Wi-Fi panel Send button:** `sendAction` beside the QR action in the network hero (`build.sh` 7e, mouse-only to leave keyboard index math alone). Keyboard path stays Setup > Network > Send Files.

### Security — hardening (applied live; fresh installs already default-safe)
- **Password sudo restored:** installer left `%wheel` + user as `NOPASSWD` (non-stock). Removed both overrides → sudo now requires auth (fingerprint once enrolled, else password). `omarchy-dns` keeps its scoped NOPASSWD rule.
- **sshd off:** `disable --now`, removed `ssh` from the public firewall zone.

### Fixed — round 6 — dead widgets, mic, DoT DNS
- **Audio sink switching:** ported `omarchy-audio-output-sink` + `omarchy-audio-sink-availability`.
- **Brightness keys dead:** `omarchy-brightness-display` exited 1 via missing `omarchy-hw-display` + `omarchy-hyprland-monitor-focused-apple`. Ported both.
- **Update indicator:** Fedora-bootc `omarchy-update-available` (pending Flatpak) + `omarchy-update` (flatpak now, `bootc upgrade` hint).
- **Reminders/monitor/agents/xkbcli:** ported `omarchy-reminder` (systemd timers), `omarchy-monitor-state`, `omarchy-agent-usage-update`; installed `libxkbcommon-utils`.
- **Mic widget:** added `omarchy.microphone` to bar right section (live + skel).
- **DNS-over-TLS:** `omarchy-dns Cloudflare` applied live (1.1.1.1 + DoT).

### Fixed — round 4–5 — lock, bluetooth, fingerprint, auto-tz, bar, media
- **Lock blank:** `qt6-qtimageformats` missing so every Lumon `.webp` failed. Installed + added to packages. Switched default wallpaper 01→02.
- **BT switch missing when off:** panel hid the switch with no adapter; `build.sh` 7c forces it visible + defaults direction to "on".
- **Fingerprint unlock + sudo:** `/etc/pam.d/omarchy-lock-fingerprint` + `authselect with-fingerprint`.
- **Auto timezone:** `omarchy-tzupdate.service` + `.timer` (boot + 12h) + NM dispatcher. Live: `America/Chicago`.
- **Bar tofu:** menu button used missing `omarchy` font; switched to Nerd Fedona `U+F30A`.
- **Media:** added `omarchy.media` to bar center; MPRIS verified via VLC.
- **Notifications:** verified (`org.freedesktop.Notifications`).
- **Clock history:** left-click now opens calendar + history, tooltip updated. Overlay staged.
- **Smaller calendar:** popup 560→392 (~30%).

### Fixed — round 3 — lock PAM, bluetooth button
- **Menu System lock did nothing:** added `etc/pam.d/omarchy-lock-password` (mirrors swaylock). `omarchy-shell lock lock` → `ok`.
- **Bluetooth toggle removed the button:** `rfkill block` unpowers the Intel USB BT device, so the bar hid the button exactly when needed. Patch keeps it visible with off icon.

### Fixed — round 2 — menu backends, login, firstrun
- **Empty apps menu:** shipped minimal `default/omarchy/omarchy-menu.jsonc` (apps provider + system/network/power/learn + screenshot).
- **SUPER+K search:** ported `omarchy-menu-select` + `perl-JSON-PP`.
- **Bluetooth toggle:** ported `omarchy-bluetooth-power` / `device` (rfkill-persist).
- **DNS providers:** ported `omarchy-dns`, `network-status/band`, `launch-floating-terminal`, + `sudoers.d/omarchy-dns`.
- **Battery info:** ported `omarchy-battery-status`, `system-stats`, `battery-low`.
- **Background setter:** `omarchy-theme-bg-set` now `mkdir -p` the state dir; overlay staged.
- **Login screen:** `sddm-themes` + derived `omarchy` theme (maldives + Lumon wallpaper).
- **Screensaver:** stub `omarchy-launch-screensaver` (exit 1) so idle falls through to lock.
- **Installer GitHub prompt:** per-user `omarchy-firstrun-github.service` (floating terminal, once, state-gated).

### Fixed — round 1 — wifi, audio, power, launcher, firstboot
- **Wi-Fi:** `iwlwifi-QuZ-a0-hr-b0-77.ucode` missing → no wlan0. Added `iwlwifi-mvm/mld/dvm + iwlegacy` + `NetworkManager-wifi`, `wpa_supplicant`, `wireless-regdb`, `iw`. Also `alsa-sof-firmware` for `sof-hda-dsp`.
- **Power profiles:** shimmed `powerprofilesctl` onto tuned-ppd D-Bus + `omarchy-powerprofiles-list/set`; enabled `tuned` alongside `tuned-ppd`.
- **SUPER+D launcher:** skel `~/.config/hypr/bindings.lua` alias for `omarchy-menu toggle apps` (native menu primary, `rofi` fallback).
- **Firstboot flakiness:** Flathub remote-add now retries 5×; unit has `Restart=on-failure`.
- **Tailscale repo:** `rpm --import` the repo key; skip duplicate repo creation.

## 2026-09-10 — initial decisions (not fixes)

1. Image viewer → keep `imv`.
2. Office → drop LibreOffice, keep `evince`.
3. Flatpak + Flathub → yes, Flathub enabled.
4. Services → Tailscale + Bitwarden added.
5. Install → ISO via `bootc-image-builder`.

## 2026-09-12 — fingerprint at install/first-boot

Enrollment needs a physical finger + existing user — can't be imaged. Everything around it is automated: `authselect with-fingerprint` + both PAM files + `fprintd.service` bake in; the firstrun unit offers `fprintd-enroll` on first login (`omarchy-setup-fingerprint`, skips silently if no reader/enrolled). Also fixed the lock screen's enrolled check matching "no fingers enrolled" (7f).
