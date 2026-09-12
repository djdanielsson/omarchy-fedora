#!/usr/bin/env bash
# Omarchy-Fedora bootc build script — runs inside container build
set -ouex pipefail

ARCH="$(uname -m)" # x86_64 or aarch64

# 1. Repos: dnf5 plugin names (this image uses dnf5, not dnf4)
dnf install -y 'dnf5-command(copr)' dnf5-plugins

# Hyprland + Omarchy ports (verified 2026-09-10 to have fedora-44 x86_64 chroots):
# - agaspar/omedora-4: hyprland, hyprpicker, hyprsunset, xdg-desktop-portal-hyprland,
#   hyprland-guiutils, uwsm, lazygit, starship, tensaku, herdr, omedora-nerd-fonts, ...
# - whelanh/omarchy: aether, cliamp, omacalc, omacut, omawrite, hyprland-preview-share-picker
# - randalthor17/caelestia-fedora: caelestia-shell + caelestia-cli built against
#   plain quickshell (gmanka/caelestia was dropped: it hard-requires quickshell-git,
#   which conflicts with stock AND omedora-4 quickshell).
# NOTE: single Hyprland source only. denorath/navigator-hyprland was dropped because its
# hyprutils 0.10 conflicts with omedora-4's hyprutils 0.13/0.14. Lock/idle use stock
# swaylock+swayidle instead of hyprlock+hypridle (see packages-common.txt).
# quickshell intentionally NOT from COPR — it is in stock Fedora 44.
for copr in agaspar/omedora-4 whelanh/omarchy randalthor17/caelestia-fedora; do
  dnf copr enable -y "$copr" || echo "WARNING: COPR $copr enable failed"
done

# RPM Fusion free+tained needed for: vlc, obs-studio extras, intel-media-driver extras, codecs
dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm || echo "WARNING: rpmfusion install failed"

# Tailscale repo (per 2026-09-10: tailscale wanted, Intel-only image)
dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo || \
  curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo || \
  echo "WARNING: tailscale repo setup failed"

dnf update -y

# 2. Main package set (see packages-common.txt for rationale / Arch->Fedora mapping)
# shellcheck disable=SC2046
dnf install -y $(grep -v '^#' /ctx/packages-common.txt | grep -v '^$' | tr '\n' ' ')

# 3. Warp terminal via official yum repo (per docs.warp.dev — the
# https://app.warp.dev/get_warp download URL returns an HTML interstitial to curl,
# so Rosa-style direct .rpm download does NOT work; repo install also gives updates)
rpm --import https://releases.warp.dev/linux/keys/warp.asc || echo "WARNING: warp key import failed"
cat > /etc/yum.repos.d/warpdotdev.repo <<'EOF'
[warpdotdev]
name=warpdotdev
baseurl=https://releases.warp.dev/linux/rpm/stable
enabled=1
gpgcheck=1
gpgkey=https://releases.warp.dev/linux/keys/warp.asc
EOF
dnf install -y warp-terminal || echo "WARNING: warp-terminal install failed"

# 4. mise (devops package manager for node/opencode/codex AI CLIs)
# Fedora has no mise-bin rpm — use upstream install to /usr/local/bin
curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

# 4b. tzupdate (not packaged for Fedora — PyPI, same tool Omarchy ships)
pip install --prefix=/usr/local tzupdate || echo "WARNING: tzupdate pip install failed"

# 5. Systemd defaults (image-mode: enable, don't start)
systemctl enable sddm.service || true
systemctl enable NetworkManager.service || true
systemctl enable bluetooth.service || true
systemctl enable cups.service || true
systemctl enable thermald.service || true
systemctl enable tuned-ppd.service || true
systemctl enable firewalld.service || true
systemctl enable podman.socket || true
systemctl enable tailscaled.service || true
systemctl enable chronyd.service || true
systemctl enable sshd.service || true
systemctl enable fprintd.service || true
systemctl enable ModemManager.service || true
systemctl enable upower.service || true
systemctl enable fwupd-refresh.timer || true
# First-boot flatpak provisioning (/var is local state — see service file)
systemctl enable omarchy-firstboot-flatpak.service || true
# Caelestia shell (lock screen) autostart if the COPR ships a user unit
systemctl --global enable caelestia-shell.service 2>/dev/null || true
# bootc auto-update check (image-mode updates come from GHCR container, not dnf)
# Weekly GHCR rebuild + `bootc upgrade` on client pulls it. Enable timer for staged check.
systemctl enable bootc-fetch-apply-updates.timer || true

# 5b. Flatpak + Flathub (per 2026-09-10: yes to flatpak) + Bitwarden
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
flatpak install -y --system flathub com.bitwarden.desktop || echo "WARNING: bitwarden flatpak install failed"
# Tailscale sysusers/tmpfiles handled by rpm; no `tailscale up` at build time

# 6. Remove anything pulled in by base we explicitly don't want
# fedora-bootc:44 is minimal already — nothing to remove here.
# We deliberately do NOT install: docker*, chromium, webapps, clang/llvm/ruby/lua toolchains.
# No second terminal per owner choice — Warp only (foot omitted on purpose).

# 7. xdg-terminal-exec default -> warp (overrides Omarchy foot default)
mkdir -p /etc/xdg/xdg-terminal-exec
printf 'warp.desktop\n' > /etc/xdg/xdg-terminal-exec/terminal.list || true

# 8. Cleanup
dnf clean all
rm -rf /var/cache/* /tmp/*
