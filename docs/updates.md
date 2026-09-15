# Updates & rollback

This is image-mode — no `dnf upgrade` on the client.

```bash
bootc status                         # tracked image + staged
sudo bootc update                    # fetch :44, stage for next boot
sudo bootc upgrade --apply --reboot  # fetch + reboot into it
sudo bootc rollback                  # previous deployment
flatpak update                       # Bitwarden, Firefox, LocalSend, etc.
```

Flatpak remotes/apps update in place; the OS itself only moves via `bootc`. The `bootc-fetch-apply-updates.timer` is enabled but the weekly GHCR rebuild is the real source.

## What "update available" means

The bar's update widget (`omarchy-update-available`) is Flatpak-aware on this port (upstream is `pacman`-based): it reports pending Flatpak updates. `omarchy-update` applies them and prints the `bootc upgrade` hint for the OS.
