# Packages

Defined in `build_files/packages-common.txt` (one per line, `#` ignored by `build_files/build.sh`).

## Desktop

Hyprland + hyprpicker/sunset, swaylock/idle (hyprlock/hypridle skipped — hyprutils conflict), `xdg-desktop-portal-hyprland/gtk`, quickshell, `hyprland-guiutils`, uwsm, `mate-polkit`, SDDM + `sddm-themes` (derived `omarchy` theme), `qt6-qtimageformats` (every Lumon wallpaper is `.webp`).

Lock screen is the Omarchy shell (`omarchy.lock`), not Caelestia — Caelestia's bar is suppressed via `excludedScreens` and only its lock would have been used, but the full dashboard leaked through so it was dropped. `swaylock` stays as fallback.

## Apps

- **Browser:** Firefox Flathub `org.mozilla.firefox` (Downloads-only sandbox, see [Security](security.md)), Warp via `releases.warp.dev` repo
- **Files:** Nautilus + sushi + gvfs-mtp/nfs/smb, evince
- **Media:** VLC + OBS + imv + ffmpeg, `libva-utils`, `intel-gpu-tools`
- **Docs:** evince only (no LibreOffice)

## System

cups + filters, `dosfstools`/`exfatprogs`/`nvme-cli`/`smartmontools`, NetworkManager + wifi stack (see below), `upower`, `xdg-desktop-portal`, libinput + `xorg-x11-drv-*` + `adwaita-cursor-theme`.

### Wi-Fi / audio firmware (must be explicit)

`linux-firmware` alone ships no iwlwifi ucode on bootc minimal. AX201 needs `iwlwifi-mvm/mld/dvm + iwlegacy` plus `NetworkManager-wifi`, `wpa_supplicant`, `wireless-regdb`, `iw`. Internal HDA DSP needs `alsa-sof-firmware` + `alsa-firmware`.

### Intel iGPU

`intel-media-driver`, `libva-intel-driver`, `mesa-vulkan/va-drivers`, `linux-firmware`.

### Power / thermals

`tuned` + `tuned-ppd` (PAM conflict: `tuned-ppd` and `power-profiles-daemon` both provide `PowerProfiles1`; Caelestia requires `tuned-ppd`, so `powerprofilesctl` is a tuned-ppd D-Bus shim in `system_files/usr/local/bin/`). `thermald`, `brightnessctl`, `ddcutil`, `bolt`, `fwupd`, `powertop`, `chrony`, `zram-generator`.

### Recovery

`openssh-server/clients`, `nano`, `waybar`, `mako`, `cliphist`.

## Containers / dev

`podman` + `podman-compose` + `distrobox`, `podman.socket`; `mise` via `https://mise.run` to `/usr/local/bin`; `tzupdate` via pip.

## Flatpak

`flatpak` + Flathub. First-boot installs Bitwarden, LocalSend, Firefox (can't bake into the image — `/var` is per-machine state). Firewall ports 53317/tcp+udp opened for LocalSend.
