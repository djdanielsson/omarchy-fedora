# omarchy-fedora-bootc

Fedora 44 `bootc` image-mode desktop with Omarchy's Hyprland UI. Reproducible, atomic, roll-backable.

- **Base:** `quay.io/fedora/fedora-bootc:44`
- **Desktop:** Hyprland 0.56.2 + Quickshell + SDDM + uwsm (ported from Omarchy)
- **Apps:** Firefox (Flathub, Downloads-only), Warp, Nautilus, VLC/OBS/imv, Neovim
- **Stack:** Flatpak/Flathub, Tailscale, Podman/Distrobox, tuned-ppd

## Quick start

See [docs/install.md](docs/install.md) for ISO vs `bootc switch`, and [docs/updates.md](docs/updates.md) for `bootc upgrade` / `flatpak update`.

```bash
# Fresh machine: flash the ISO artifact, install via Anaconda.
# Existing Atomic/bootc machine:
sudo bootc switch --enforce-container-sigpolicy ghcr.io/djdanielsson/omarchy-fedora:44
```

First boot prompts for GitHub (`user.name`/`email` + `gh auth`) and offers fingerprint enrollment, then:

```bash
sudo tailscale up
mise trust && mise install
```

## Docs

- [Install](docs/install.md) · [Updates & rollback](docs/updates.md) · [Packages](docs/packages.md)
- [Configuration](docs/configuration.md) · [Theming](docs/theming.md) · [Security](docs/security.md)
- [Fingerprint](docs/fingerprint.md) · [Troubleshooting](docs/troubleshooting.md)
- [Changelog](CHANGELOG.md)

## Repo layout

```
Containerfile                  # FROM fedora-bootc:44
build_files/build.sh           # repos, dnf, flatpak, services, QML patches
build_files/packages-common.txt# package set (one per line, # comments stripped)
system_files/                  # /usr + /etc overlay (sddm session, PAM, skel, bin shims)
docs/                          # install/updates/packages/configuration/theming/security
.github/workflows/build.yml   # GHCR push on main + weekly rebuild, ISO via bootc-image-builder
```
