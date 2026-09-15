# Troubleshooting

- **No Wi-Fi (AX201):** image must include `iwlwifi-mvm/mld/dvm + iwlegacy` + `NetworkManager-wifi`/`wpa_supplicant`/`wireless-regdb`/`iw`. Verify: `journalctl -k | grep iwlwifi` should show firmware 77 loaded, `nmcli device` shows `wlp0s20f3`.
- **Lock shows "missing-pam":** `etc/pam.d/omarchy-lock-password` must exist (ships now). Check `omarchy-shell lock status`.
- **Bluetooth button vanished when off:** `rfkill block` unpowers the Intel USB BT device, so the bar hid it. Patched to stay visible with off icon.
- **SDDM / login theme:** `sddm-themes` installed, derived `omarchy` theme from maldives.
- **Auto timezone stuck on UTC:** check `omarchy-tzupdate.timer` + NM dispatcher; `timedatectl` and `journalctl -u omarchy-tzupdate`.
- **LocalSend not saving:** Flatpak needs `home` on Atomic; check `flatpak info --show-permissions org.localsend.localsend_app`.
- **Portal pickers huge:** pinned `xdg-desktop-portal-gtk` to 900×620 via `looknfeel.lua` skel.
- **Wallpaper not showing:** `qt6-qtimageformats` required for `.webp`.

## Omarchy ports (same UI for the moment)

Omarchy Arch paths → Fedora image dest (see repo `docs/` for the full table — omitted here for brevity, tracked in git history).
