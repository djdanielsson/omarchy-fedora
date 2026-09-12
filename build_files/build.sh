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
# 2026-09-12 fix: import repo GPG key non-interactively, otherwise every dnf
# run prompts "Is this ok [y/N]" + "repomd.xml GPG signature verification
# error: Signing key not found" (seen live on T14s).
rpm --import https://pkgs.tailscale.com/stable/fedora/repo.gpg || echo "WARNING: tailscale key import failed"
if [[ ! -f /etc/yum.repos.d/tailscale.repo ]]; then
  dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo || \
    curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo || \
    echo "WARNING: tailscale repo setup failed"
fi

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
systemctl enable tuned.service || true
systemctl enable tuned-ppd.service || true
systemctl enable firewalld.service || true
# LocalSend (LAN share, Flathub at first boot): allow its port through the
# default public zone in the image so discovery works out of the box.
firewall-cmd --permanent --add-port=53317/tcp 2>/dev/null || true
firewall-cmd --permanent --add-port=53317/udp 2>/dev/null || true
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
# First-run per-user GitHub setup prompt (runs once on first login)
systemctl --global enable omarchy-firstrun-github.service || true
# Auto timezone from location (tzupdate via timer + NM dispatcher)
systemctl enable omarchy-tzupdate.timer || true
# sudoers for passwordless desktop helpers (DNS switch from UI)
chmod 0440 /etc/sudoers.d/omarchy-dns 2>/dev/null || true
# Caelestia shell (lock screen) autostart if the COPR ships a user unit
systemctl --global enable caelestia-shell.service 2>/dev/null || true
# bootc auto-update check (image-mode updates come from GHCR container, not dnf)
# Weekly GHCR rebuild + `bootc upgrade` on client pulls it. Enable timer for staged check.
systemctl enable bootc-fetch-apply-updates.timer || true

# Fingerprint auth via Fedora-native authselect (sudo through system-auth).
# No enrolled fingers at build time; pam_fprintd ignores and password applies
# until the user runs fprintd-enroll. Idempotent.
authselect enable-feature with-fingerprint || echo "WARNING: authselect fingerprint failed"

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

# 7b. SDDM "omarchy" theme = stock maldives + Lumon wallpaper (2026-09-12).
# Vendoring the whole theme in git is wasteful; derive it at build time.
if [[ -d /usr/share/sddm/themes/maldives ]]; then
  rm -rf /usr/share/sddm/themes/omarchy
  cp -r /usr/share/sddm/themes/maldives /usr/share/sddm/themes/omarchy
  sed -i 's|^background=.*|background=/usr/share/omarchy-fedora/themes/lumon/backgrounds/02-opinions-equally.webp|' /usr/share/sddm/themes/omarchy/theme.conf
  sed -i 's/^Name=.*/Name=Omarchy/; s/^Theme-Id=.*/Theme-Id=omarchy/' /usr/share/sddm/themes/omarchy/metadata.desktop
fi

# 7c. Bluetooth bar button must survive rfkill-off (2026-09-12).
# rfkill block unpowers the Intel USB BT device (usb 1-10 disconnect), so
# BlueZ reports no adapter and `visible: adapter !== null` hides the button
# exactly when the user needs it to toggle back on. Keep it always visible
# with the off icon instead.
BT_PANEL=/usr/share/omarchy-fedora/shell/plugins/panels/bluetooth/Panel.qml
if [[ -f $BT_PANEL ]]; then
  sed -i 's|if (!adapter) return ""|if (!adapter) return "󰂲"|' "$BT_PANEL"
  python3 - "$BT_PANEL" <<'EOF' || echo "WARNING: bluetooth Panel.qml visible patch failed"
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = "visible: adapter !== null"
assert old in s, "visible gate not found"
s = s.replace(old, "// Fedora fix (see 7c above): keep button to re-enable.\n  visible: true", 1)
old_fn = """  function toggleBluetooth() {
    if (!adapter) return
    Quickshell.execDetached(["omarchy-bluetooth-power", adapter.enabled ? "off" : "on"])
  }"""
new_fn = """  function toggleBluetooth() {
    // Fedora fix: no adapter (rfkill-off) means direction is "on".
    Quickshell.execDetached(["omarchy-bluetooth-power", adapter && adapter.enabled ? "off" : "on"])
  }"""
assert old_fn in s, "toggle fn not found"
s = s.replace(old_fn, new_fn, 1)
old_sw = """          ToggleSwitch {
            id: powerSwitch
            visible: !!root.adapter"""
new_sw = """          ToggleSwitch {
            id: powerSwitch
            // Fedora fix: keep the switch with no adapter, else no way back on.
            visible: true"""
assert old_sw in s, "power switch not found"
s = s.replace(old_sw, new_sw, 1)
open(p, "w", encoding="utf-8").write(s)
EOF
fi

# 7d. Calendar popup ~30% smaller (2026-09-12): at 560 wide it eats half a
# 1080p screen. Scale cells + hero + popup together so nothing clips.
CAL_PANEL=/usr/share/omarchy-fedora/shell/plugins/panels/clock/Panel.qml
if [[ -f $CAL_PANEL ]]; then
  python3 - "$CAL_PANEL" <<'EOF' || echo "WARNING: clock Panel.qml scale patch failed"
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
subs = [
  ("readonly property int cellWidth: Style.space(52)", "readonly property int cellWidth: Style.space(36)"),
  ("readonly property int cellHeight: Style.space(34)", "readonly property int cellHeight: Style.space(24)"),
  ("readonly property int weekColumnWidth: Style.space(32)", "readonly property int weekColumnWidth: Style.space(22)"),
  ("readonly property int gutterWidth: Style.space(14)", "readonly property int gutterWidth: Style.space(10)"),
  ("contentWidth: panel.fittedContentWidth(Style.space(560))", "contentWidth: panel.fittedContentWidth(Style.space(392))"),
  ("font.pixelSize: 48", "font.pixelSize: 34"),
  ("font.pixelSize: 52", "font.pixelSize: 36"),
]
for old, new in subs:
    assert s.count(old) == 1, f"pattern not unique/found: {old}"
    s = s.replace(old, new, 1)
open(p, "w", encoding="utf-8").write(s)
EOF
fi

# 8. Cleanup
dnf clean all
rm -rf /var/cache/* /tmp/*
