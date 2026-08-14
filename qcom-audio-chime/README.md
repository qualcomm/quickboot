# qcom-audio-chime

Qualcomm QuickBoot Early Audio Chime — Meson build.

Plays a boot chime via PipeWire immediately after the audio pipeline is ready.
Used as a **time-to-first-sound** measurement checkpoint for QuickBoot profiling.

## Files installed

| Source | Destination | Mode |
|--------|-------------|------|
| `files/audio-chime` | `<prefix>/bin/audio-chime` | `0755` |
| `files/sample-3s.wav` | `<prefix>/share/sounds/sample-3s.wav` | `0644` |
| `files/audio-chime.service` | `<systemd_dir>/audio-chime.service` | `0644` |

## Build (Meson)

```sh
meson setup builddir --prefix=/usr
meson install -C builddir --destdir=/path/to/sysroot
```

To override the systemd unit directory (e.g. for a Yocto sysroot):

```sh
meson setup builddir \
    --prefix=/usr \
    -Dsystemd_system_unit_dir=/lib/systemd/system
meson install -C builddir --destdir=/path/to/sysroot
```

## Install (standalone shell script)

A single `install.sh` at the top level installs **both** demo apps
(`qcom-audio-chime` and `qcom-camera-preview`) in one step.

```sh
# From the parent directory — install to live rootfs (requires root)
../install-apps.sh

# Install into a sysroot
../install-apps.sh /mnt/target

# Override directories
PREFIX=/usr SYSTEMD_DIR=/lib/systemd/system ../install-apps.sh /mnt/target
```

Both services are enabled automatically by creating
`multi-user.target.wants/` symlinks — no running systemd required.

## Service

`audio-chime.service` is a **oneshot** unit that:

- Requires and starts after `pipewire.service`
- Runs `/usr/bin/audio-chime /usr/share/sounds/sample-3s.wav`
- Logs playback events to both the systemd journal and `/dev/kmsg` for
  kernel-level boot timing correlation

Service enabling is handled by the image recipe (`SYSTEMD_AUTO_ENABLE`
in BitBake / equivalent in other build systems). No `systemctl enable`
hook is run at install time.

## Runtime dependencies

- `pipewire` / `pw-play`
- `sh` (POSIX shell)
