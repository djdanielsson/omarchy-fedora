# Install

## Container is source of truth

Every push to `main` and the weekly rebuild publish:

- `ghcr.io/djdanielsson/omarchy-fedora:45` — tracked, `bootc upgrade` pulls this
- `ghcr.io/djdanielsson/omarchy-fedora:YYYYMMDD-45` — pinned backup

The ISO artifact `omarchy-fedora-45-iso` is built *from* `:45` and is only the installer.

## Fresh machine — ISO

1. Download `omarchy-fedora-45-iso` from Actions.
2. Flash to USB, boot, install via Anaconda.
3. First boot already tracks `:45`; Flathub/Bitwarden/LocalSend/Firefox/Steam install via `omarchy-firstboot-flatpak.service` (see [Configuration](configuration.md#first-boot)).

## Existing Atomic/bootc machine — rebase

No reinstall needed:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/djdanielsson/omarchy-fedora:45
sudo systemctl reboot
```

## First boot checklist

The firstrun unit (`omarchy-firstrun-github.service`) opens a floating terminal once per user to set `git user.name`/`email` and `gh auth`, plus offers `fprintd-enroll`. See [Fingerprint](fingerprint.md).

Then:

```bash
sudo tailscale up
mise trust && mise install   # node/opencode/codex from ~/.config/mise/config.toml
```

Timezone sets itself via `tzupdate` (timer + NetworkManager dispatcher); verify with `timedatectl`.
