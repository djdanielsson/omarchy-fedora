# Fingerprint

The reader is a Synaptics 06cb:00bd. Image bakes `fprintd` + `fprintd-pam`, enables `fprintd.service`, and does `authselect enable-feature with-fingerprint` (sudo via `system-auth`). The lock screen has `etc/pam.d/omarchy-lock-password` (password) and `omarchy-lock-fingerprint` (fprintd) — patched live so "no fingers enrolled" doesn't false-positive.

## Enroll

Enrollment needs your physical finger + existing user — can't be imaged. On first login the firstrun unit offers it; otherwise:

```bash
fprintd-enroll
fprintd-verify       # one more swipe
```

Then touch-to-unlock works (icon in the password field) and `sudo` tries the reader before password.

## Fixups

`build.sh` 7f fixes the lock Service.qml enrolled check (`found [1-9]` + not `no fingers enrolled`), which previously showed a phantom icon and spammed PAM errors.
