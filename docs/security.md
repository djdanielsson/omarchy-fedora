# Security

- **Sudo:** no NOPASSWD on fresh installs. Live laptop had it and it was removed; `omarchy-dns` keeps a scoped NOPASSWD rule. After reboot, `sudo` requires auth (fingerprint once enrolled, else password). Set up fingerprint via [Fingerprint](fingerprint.md).
- **Firewall:** `firewalld`, default zone `public`, `ssh` removed, 53317/tcp+udp added for LocalSend.
- **sshd:** disabled by default (`disable --now` on the live laptop; image never enables it except for Warp-failure fallback). Re-enable: `sudo systemctl enable --now sshd` + firewall rule if needed.
- **Supply chain:** Fedora container base (`fedora:43@sha256:…` in the sandbox, bootc base `quay.io/fedora/fedora-bootc:44`) + COPR/RPM Fusion verified at build; `mise` + `tzupdate` via pip executed inside the build.
- **AI sandbox:** see `~/ai-development-sandbox` — Podman devcontainer with biometric-aware `bwbio` launchers (`fedora-host/README.md` for the Linux port). Lock screen and sudo already gate on fingerprint via PAM.

## Flatpak sandboxes

- Firefox (`org.mozilla.firefox`) limited to `xdg-download` only (host/home revoked via overrides, portal pickers still work there).
- LocalSend needs `home` on Atomic (`/home` → `/var/home` symlink breaks the default `xdg-download` mount) — granted via override, verified live.
- Bitwarden keeps its default sandbox (secrets via portal).
