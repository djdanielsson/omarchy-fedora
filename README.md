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
* Dropped with no Fedora equivalent: `inetutils`, `gnome-themes-extra`, split `iwl*-firmware` (covered by `linux-firmware`).
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
