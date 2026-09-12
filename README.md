# omarchy-fedora-bootc

Fedora 44 `bootc` image-mode desktop with Omarchy's Hyprland UI, your package set.
**Local build: GREEN** (`podman build` → `localhost/omarchy-fedora:44`, `bootc container lint` 10 passed).

Verified in image: `hyprland 0.56.2` (= Omarchy), `uwsm`, `quickshell 0.3.0-git`
(omedora-4), `caelestia-shell 1.0.0 + cli`, `warp-terminal` (official repo),
`firefox`, `vlc`, `obs-studio`, `imv`, `neovim`, `mise`+`tzupdate` (/usr/local),
`tailscale`, `distrobox`, `tuned-ppd`, `sddm`, `swaylock/idle` fallback.

* **Base:** `quay.io/fedora/fedora-bootc:44`
* **UI:** Hyprland + Quickshell + SDDM + uwsm (ported from Omarchy 4.0.3 configs)
* **Swap:** Warp (rpm) + Firefox — no foot, no chromium, **no webapps**
* **Files:** Nautilus + sushi + gvfs (same as Omarchy)
* **Media:** VLC + OBS + imv (imv kept for Omarchy menus/screenshots)
* **Containers:** podman + podman-compose + distrobox (no docker)
* **Keep:** all CLI TUIs (`bat/eza/fd/fzf/rg/btop/du/lazygit/tmux/starship/zoxide/yt-dlp`…), neovim, mise AI (`node/opencode/codex`)
* **Drop:** compilers/dev (`clang/llvm/ruby/lua/dotnet`), webapp SSBs, all LibreOffice (evince kept)
* **Drivers:** Intel iGPU only
* **Extras 2026-09-10:** Flatpak + Flathub enabled, Bitwarden (flatpak), Tailscale (rpm), ISO-first install

## Quick start (container is source of truth, ISO is installer)

```bash
# Every push to main + weekly rebuild publishes:
#   ghcr.io/<you>/omarchy-fedora:44          <- tracked, `bootc upgrade` pulls this
#   ghcr.io/<you>/omarchy-fedora:YYYYMMDD-44 <- pinned backup
# Plus ISO artifact `omarchy-fedora-44-iso` built FROM :44

# Fresh machine: flash ISO -> install via Anaconda -> first boot already tracks :44.
# Existing bootc/Atomic machine: rebase without reinstall:
sudo bootc switch --enforce-container-sigpolicy ghcr.io/<you>/omarchy-fedora:44
sudo systemctl reboot

# First boot automatically: Flathub remote + Bitwarden flatpak
# (omarchy-firstboot-flatpak.service — /var is per-machine state, so flatpak
# cannot be baked into the image). Then:
sudo tailscale up
mise trust && mise install  # node/opencode/codex from ~/.config/mise/config.toml

# Updates (this is image-mode — no dnf upgrade on client):
bootc status                    # shows tracked image
sudo bootc update               # fetch :44, stage for next boot
sudo bootc upgrade --apply --reboot  # fetch + reboot into it
sudo bootc rollback             # back to previous deployment
flatpak update                  # Bitwarden etc. still via flatpak
```

## Repo layout

```
Containerfile                  # FROM fedora-bootc:44
build_files/build.sh           # dnf + warp rpm + mise + systemctl enable
build_files/packages-common.txt# your package set (Arch->Fedora mapped)
system_files/                  # /usr + /etc overlay (wayland session, terminal default, skel mise)
.github/workflows/build.yml   # GHCR weekly build
```

## Porting Omarchy UI (same UI for the moment)

Omarchy Arch paths → copy into `system_files/`:

| Omarchy (Arch now) | Fedora image dest | Notes |
|---|---|---|
| `/usr/share/omarchy/default/hypr/` | `/usr/share/omarchy-fedora/hypr/` + `~/.config/hypr/` skel | Lua-based hypr config, mostly portable. Replace `foot` binds with `warp`, `chromium` with `firefox` |
| `/usr/share/omarchy/shell/` (Quickshell QML) | `/usr/share/omarchy-fedora/shell/` | Needs `quickshell` COPR on F44 — build.sh enables `heus-sueh/quickshell` fallback |
| `/usr/share/omarchy/default/sddm/` | `/etc/sddm.conf.d/` | SDDM works on bootc, keep theme |
| `/usr/share/omarchy/themes/*` (20 themes, now `Lumon`) | `/usr/share/themes/` + skel | Copy whole dir, set `Lumon` default |
| `/usr/share/omarchy/default/fontconfig/fonts` | `/etc/fonts/` | JetBrainsMono Nerd + Noto + FA |
| `omarchy-*` 441 helpers | **do not copy wholesale** — Arch-only (`pacman`, `limine`, `snapper`) | Port only `capture/*`, `theme-*`, `menu/*`, rewrite pkg/install bits to `dnf`/`bootc` |
| `webapps/*.desktop` | **deleted** per spec |  |
| `xdg-terminal-exec/terminal.list` | `system_files/etc/xdg/...` already set to `warp.desktop` |  |

Next step: `rsync -a /usr/share/omarchy/{shell,themes,default/hypr} ./system_files/usr/share/omarchy-fedora/` then search-replace `foot→warp-terminal`, `chromium→firefox`, `pacman→dnf`, `yay→dnf copr`, `docker→podman`.

## Fedora deltas to know

* `fd-find` provides `fd`, `du-dust`/`dua-cli` split, `pipewire-pulseaudio` not `pipewire-pulse`, `evince` kept (LibreOffice dropped).
* `ufw` → `firewalld` (Atomic default). `limine/snapper` → ostree rollback + `bootc`.
* Warp via official yum repo `releases.warp.dev/linux/rpm/stable` (package `warp-terminal`, key imported in build.sh). NOTE: `https://app.warp.dev/get_warp?package=rpm` returns an HTML page to curl — direct .rpm download does not work headless, hence the repo.
* Lock screen: Caelestia (`caelestia-shell` + `caelestia-cli` via COPR `randalthor17/caelestia-fedora`, currently 1.0.0 — older than upstream but built against plain quickshell; `gmanka/caelestia` 1.6.2 was rejected: it hard-requires conflicting `quickshell-git`). Lock-only mode — Omarchy bar stays primary.
* `mise` via `https://mise.run` to `/usr/local/bin` (`/usr` is read-only at runtime, `/usr/local/bin` persists via image).
* RPM Fusion required for `vlc`, full `obs-studio` codecs, Intel media extras.
* Hyprland is NOT in stock Fedora 44 — COPRs (verified F44 x86_64, see `build.sh`): `agaspar/omedora-4` (hyprland/picker/sunset/portal/guiutils/uwsm/lazygit/starship/tensaku/herdr/nerd-fonts — a Fedora Omarchy port), `denorath/navigator-hyprland` (hyprlock/hypridle/qtutils), `whelanh/omarchy` (aether/cliamp/omacalc/omawrite). `quickshell` IS stock.
* Polkit agent: `mate-polkit` (stock). Nerd Fonts: `omedora-nerd-fonts`. `starship`/`lazygit` via omedora-4. `tzupdate` via pip.
* Dropped with no Fedora equivalent: `inetutils`, `gnome-themes-extra`.
* Wi-Fi firmware MUST be explicit on bootc minimal (2026-09-12 fix): `linux-firmware`
  alone ships no iwlwifi ucode — AX201 fails `no suitable firmware`, no wlan0.
  Image now includes `iwlwifi-mvm/mld/dvm + iwlegacy` plus `NetworkManager-wifi`,
  `wpa_supplicant`, `wireless-regdb`, `iw`. Audio needs `alsa-sof-firmware`
  (internal HDA DSP) + `alsa-firmware`, also explicit.
* Tailscale via `pkgs.tailscale.com` repo, `tailscaled.service` enabled — run `tailscale up` after install.
* Bitwarden via Flathub `com.bitwarden.desktop` baked at build time; `flatpak update` keeps it current.

## Lock screen: Caelestia, lock-only

Caelestia ships no standalone lock package — the lock lives inside the full
shell (`qs -c caelestia`). We run it detached and suppress everything else:

* `system_files/etc/skel/.config/caelestia/shell.json` — `background.enabled=false`
  (Omarchy theming stays in charge), `lock.enabled=true`.
* `omarchy-caelestia-lock-only` (run at login, Hyprland `exec-once`) — detects
  outputs via `hyprctl monitors -j` and writes them to `bar.excludedScreens`,
  so the Caelestia bar never draws or reserves space. Verified against
  Caelestia's `BarConfig`/`BarWrapper`: excluded screens collapse to zero width.
* `omarchy-lock` — ensures the shell is up, then `caelestia shell lock lock`.
  Bind it (SUPER+L), call it from swayidle, call it before sleep:
  ```
  exec-once = omarchy-caelestia-lock-only
  exec-once = caelestia shell -d
  bind = SUPER, L, exec, omarchy-lock
  exec-once = swayidle -w timeout 300 'omarchy-lock' before-sleep 'omarchy-lock'
  ```
* `swaylock` stays installed as fallback. Caelestia needs stock Fedora 44
  `quickshell` 0.2.1^git (satisfies its quickshell-git requirement).

Known tradeoff: Caelestia registers Hyprland global shortcuts (launcher,
dashboard, nexus). They live in a separate namespace from Omarchy binds, but
Hyprland may show an approval prompt on first use — approve or ignore.

## Done 2026-09-10

1. ~~Image viewer~~ → keep `imv`.
2. ~~Office~~ → drop all LibreOffice, keep `evince`.
3. ~~Flatpak~~ → yes, Flathub enabled.
4. ~~Services~~ → Tailscale + Bitwarden added. 1Password/Signal/Spotify still out.
5. ~~Install~~ → ISO via `bootc-image-builder` job in Actions.

## Fixes 2026-09-12 (verified live on T14s AX201)

* **Wi-Fi:** `iwlwifi-QuZ-a0-hr-b0-77.ucode` missing → no wlan0.
  Fixed by explicit `iwlwifi-mvm/mld/dvm + iwlegacy` + `NetworkManager-wifi`,
  `wpa_supplicant`, `wireless-regdb`, `iw`. Live test: `modprobe -r iwlwifi;
  modprobe iwlwifi` → `wlp0s20f3` appears, scan lists SSIDs.
* **Power profiles:** shell/menu call `powerprofilesctl` + `omarchy-powerprofiles-list/set`,
  none shipped. Fixed with `system_files/usr/local/bin/powerprofilesctl` shim
  (tuned-ppd D-Bus) + upstream list/set scripts. `tuned` now explicitly enabled
  alongside `tuned-ppd`.
* **SUPER+D launcher:** no binding existed (only SUPER+SPACE / SUPER+ALT+SPACE).
  Fixed with skel `~/.config/hypr/bindings.lua` alias:
  `o.bind("SUPER + D", "Apps menu", "omarchy-menu toggle apps")`.
  Native quickshell apps menu is primary; `rofi` kept explicitly as fallback.
* **Internal audio:** `alsa-sof-firmware` missing → `sof-hda-dsp` probe fails,
  only USB dock audio. Fixed by adding `alsa-sof-firmware` (+ `alsa-firmware`).
* **Firstboot flakiness:** Flathub remote-add raced DNS at boot. Script now retries
  5× with backoff; unit has `Restart=on-failure`.
* **Tailscale repo:** key never imported → every dnf prompted GPG. `build.sh` now
  `rpm --import` the key and skips duplicate repo creation.

## Fixes 2026-09-12 (round 2 — menu backends, login, firstrun)

* **Empty apps menu:** `default/omarchy/omarchy-menu.jsonc` was never shipped, so
  `omarchy-menu toggle apps` fell back to an empty root card. Added minimal
  Fedora menu (`apps` provider + system/setup-network-DNS/setup-power/learn).
  Live: `omarchy menu refresh` → apps submenu resolves, no shell errors.
* **SUPER+K search:** `omarchy-menu-keybindings` shelled out to missing
  `omarchy-menu-select`. Ported upstream select (shell summon mode) + added
  `perl-JSON-PP` to packages. Live: keybindings menu opens and is searchable;
  `--print` also works headless.
* **Bluetooth toggle:** panel called missing `omarchy-bluetooth-power/device`.
  Ported both (bluetoothctl + rfkill-persist). Live: off/on round-trips,
  `is-on` exit codes correct.
* **DNS providers:** panel/menu called missing `omarchy-dns`, `omarchy-network-status`,
  `omarchy-network-band`, `omarchy-launch-floating-terminal-with-presentation`.
  Ported all (DNS patched to `/usr/local/bin` path) + `etc/sudoers.d/omarchy-dns`
  for passwordless UI switching. Live: `omarchy-dns` get/set Cloudflare/revert DHCP verified.
* **Battery info:** power panel polled missing `omarchy-battery-status` and
  `omarchy-system-stats` (plus `omarchy-battery-low` hook). Ported all; live
  `--shell` reports 99%, thresholds 75-80%, cycles.
* **Background setter:** `omarchy-theme-bg-set` never `mkdir -p` the state dir,
  so first set failed. Fixed + overlay in
  `system_files/usr/share/omarchy-fedora/bin/`. Live: Lumon wallpaper set.
  Theme defaulted to Lumon via `omarchy-theme-set`.
* **Login screen:** SDDM had no theme (`Current` unset, empty themes dir).
  Image now installs `sddm-themes`; `build.sh` derives an `omarchy` theme from
  maldives with the Lumon wallpaper; `etc/sddm.conf.d/omarchy.conf` sets
  `Current=omarchy`.
* **Screensaver:** upstream launcher needs Alacritty/Foot/Ghostty/Kitty; image
  is Warp-only, so idle cycles logged process-start with no window. Shipped a
  stub `omarchy-launch-screensaver` (exit 1) so the cycle falls through to
  `omarchy-system-lock` at the lock timeout.
* **Installer GitHub prompt:** Anaconda ISO has no custom questions, so added a
  per-user first-run unit (`omarchy-firstrun-github.service`, global-enabled)
  launching `omarchy-setup-github` in a floating terminal: git user.name/email
  + `gh auth login`, once (state file gated).

## Fixes 2026-09-12 (round 3 — lock PAM, bluetooth button)

* **Menu System lock did nothing:** the shell lock service gates on
  `/etc/pam.d/omarchy-lock-password` and returns `missing-pam` without it —
  the file was never shipped. Added
  `system_files/etc/pam.d/omarchy-lock-password` (mirrors swaylock).
  Live: `omarchy-shell lock lock` went from `missing-pam` to `ok`,
  `locked:true secure:true`.
* **Bluetooth toggle removed the button:** `rfkill block` unpowers the Intel
  USB BT device (`usb 1-10 disconnect`), so BlueZ reports no adapter and the
  bar widget's `visible: adapter !== null` hid the button exactly when needed
  to re-enable. `build.sh` now patches the vendored QML (always visible + off
  icon when adapter is null); same patch applied live and verified across a
  shell restart with BT off (no QML errors).

## Fixes 2026-09-12 (round 4 — lock wallpaper, BT toggle, fingerprint PAM)

* **Lock showed blank + input box:** Qt had no WebP decoder (`qt6-qtimageformats`
  missing) so every Lumon `.webp` failed (`Unsupported image format` in shell
  log) on desktop AND lock. Installed live + added to packages. Also switched
  default wallpaper 01→02 (`opinions-equally`, livelier blurred on lock).
* **BT switch missing when off:** the panel's `ToggleSwitch visible:
  !!root.adapter` hid the switch with no adapter, and `toggleBluetooth()`
  returned early on null — no way back on from UI. `build.sh` 7c now also
  forces the switch visible and defaults the direction to `"on"`. Live-verified
  via the panel's own IPC from the off state.
* **Fingerprint unlock:** `/etc/pam.d/omarchy-lock-fingerprint` shipped (live +
  repo). Remaining step is per-user: run `fprintd-enroll`, then touch-to-unlock
  works (icon appears in the password field).

* **Fingerprint for sudo:** enabled Fedora-native
  `authselect enable-feature with-fingerprint` (live + `build.sh`), so sudo
  tries the reader first via system-auth and falls back to password. Same
  prerequisite: `fprintd-enroll`.

## Fixes 2026-09-12 (round 5 — tzupdate auto-tz, Fedora bar icon, media, notifications)

* **Auto timezone from location:** `tzupdate` was installed but never run
  (stuck on UTC). Added `omarchy-tzupdate.service` + `.timer` (boot + 12h,
  persistent) plus NM dispatcher `99-omarchy-tzupdate` on FULL connectivity.
  Live: timer fired SUCCESS, zone now America/Chicago.
* **Top-left bar tofu:** menu button used PUA glyph `U+E900` in nonexistent
  `omarchy` font. Switched to Nerd `U+F30A` (Fedora logo) in JetBrainsMono
  Nerd (verified coverage via `fc-list :charset=`); overlay staged at
  `system_files/.../menu/BarWidget.qml`. Live screenshot confirms logo.
* **Media controls:** `omarchy.media` service existed but disabled (no bar
  widget in layout). Added to bar center (live `shell.json` + skel for new
  users). Verified end-to-end: VLC+MPRIS, `omarchy-shell media playPause`
  toggles Playing/Paused, so XF86 keys work; widget shows now-playing when active.
* **Notifications:** verified working — Omarchy shell owns
  `org.freedesktop.Notifications`, `notify-send` popups render (screenshot).
* **WebP wallpapers (found via lock work):** added `qt6-qtimageformats` —
  without it every Lumon `.webp` failed on desktop AND lock.

* **Clock opens notification history:** left-click on the time/date button now
  opens history (`showHistory`); middle-click kept the calendar, right-click
  still cycles format. Tooltip advertises it. Overlay staged at
  `system_files/.../panels/clock/BarWidget.qml`.

* **Smaller calendar:** popup was ~830px on 1080p. `build.sh` 7d scales clock
  cells 52→36, hero 52/48→36/34, popup 560→392 (~30%). Screenshot-verified,
  no clipping.

## Fixes 2026-09-12 (round 6 — dead widgets, mic, DoT DNS)

* **Audio sink switching:** `omarchy-audio-output-sink` +
  `omarchy-audio-sink-availability` missing (BT audio routing, polled
  constantly). Ported (pactl-based). Live: resolves SOF speaker sink.
* **Brightness keys dead:** `omarchy-brightness-display` exited 1 via missing
  `omarchy-hw-display` + `omarchy-hyprland-monitor-focused-apple`. Ported both;
  bare/`--monitor`/monitor-state all report 100%.
* **Update indicator:** upstream is pacman-based; rewrote Fedora-bootc
  `omarchy-update-available` (pending Flatpak updates) + `omarchy-update`
  (flatpak now, `bootc upgrade` hint). Live: correctly reports up to date.
* **Reminders/monitor/agents/xkbcli:** ported `omarchy-reminder`
  (systemd timers), `omarchy-monitor-state`, `omarchy-agent-usage-update`
  (no-op without collectors); installed `libxkbcommon-utils` (keybindings
  picker). All exit 0 live.
* **Mic widget:** `omarchy.microphone` files existed, just absent from bar
  layout. Added to right section (live + skel `shell.json`).
* **DNS-over-TLS:** `omarchy-dns Cloudflare` applied live (1.1.1.1 + DoT,
  Quad9 fallback); resolution verified.

## Hardening 2026-09-12 (applied live; fresh installs already default-safe)

* **Password sudo restored:** installer left `%wheel` + user as `NOPASSWD`
  (non-stock). Removed both overrides → sudo now requires auth (fingerprint
  once enrolled, else password). `omarchy-dns` keeps its scoped NOPASSWD rule.
* **sshd off:** laptop doesn't serve SSH; `disable --now`, removed `ssh` from
  the public firewall zone. Re-enable with
  `sudo systemctl enable --now sshd` + firewall rule if ever needed.

## Fixes 2026-09-12 (round 7 — wifi QR, speedtests, LocalSend)

* **Wi-Fi QR + password:** panels called missing `omarchy-network-qr` /
  `omarchy-network-password` (nmcli secrets + qrencode). Ported; live matrix
  generates for the active wifi. Note: opening QR while on ethernet-only
  correctly reports no shareable Wi-Fi.
* **Speedtests:** `omarchy-network-speedtest` (fast.com curl phases) and
  `omarchy-disk-speedtest` (direct-I/O workers) ported. Live: down ~70 Mbps
  streaming numbers; NVMe read ~1650 / write ~1000 MB/s.
* **LocalSend (open AirDrop alt):** Flathub `org.localsend.localsend_app`
  added to first-boot installs; firewall 53317/tcp+udp opened in image.

* **Network menu QR + Send Files:** added `setup.network.qr` (summons wifiqr
  panel) and `setup.network.send` (launches LocalSend) to the default menu so
  sharing sits next to Wi-Fi controls.

* **Wi-Fi panel Send button:** `sendAction` beside the QR action in the network
  hero (`build.sh` 7e, mouse-only to leave keyboard index math alone).
  Keyboard path stays Setup > Network > Send Files.

* **Portal pickers sized:** file choosers opened fullscreen-ish on 1080p.
  Pinned `xdg-desktop-portal-gtk` to centered 900x620 (live looknfeel + skel).

## Fixes 2026-09-12 (round 8 — lumon-tux theme, dark default, wifi send button)

* **lumon-tux theme:** new `usr/share/omarchy-fedora/themes/lumon-tux/`
  (electric-cyan `#46d4f2` accent, amber secondary, near-black grounds,
  cyan Hyprland borders) matched to the Tux-glow wallpaper, which ships in its
  `backgrounds/` (live-tested via user theme copy first).
* **Dark default:** `etc/dconf/db/local.d/00-darkmode` (Adwaita-dark +
  prefer-dark) + `dconf update` in build; live system already reported dark.
* **Wi-Fi panel Send button + menu QR/Send entries** (see round 7) committed;
  LocalSend firstboot override generalized to `--filesystem=home`.
