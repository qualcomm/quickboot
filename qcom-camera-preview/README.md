# qcom-camera-preview

Qualcomm QuickBoot Early Camera Preview — Meson build.

Displays a live camera preview via Weston immediately after the camera pipeline
and display are ready. Used as a **time-to-first-frame** measurement checkpoint
for QuickBoot profiling.

## Files installed

| Source | Destination | Mode |
|--------|-------------|------|
| `files/camera-preview` | `<prefix>/bin/camera-preview` | `0755` |
| `files/camera-preview.service` | `<systemd_dir>/camera-preview.service` | `0644` |

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

`camera-preview.service` is a **simple** unit that:

- Requires and starts after `cam-server.service` and `weston.service`
- Runs `/usr/bin/camera-preview` (GStreamer pipeline via `gst-launch-1.0`)
- Sets `WAYLAND_DISPLAY=/run/wayland-0` for Wayland compositor access
- Restarts automatically on failure

Service enabling is handled by the image recipe (`SYSTEMD_AUTO_ENABLE`
in BitBake / equivalent in other build systems). No `systemctl enable`
hook is run at install time.

## Runtime dependencies

- `gstreamer1.0` / `gst-launch-1.0`
- `gst-plugins-qti-oss` (qtiqmmfsrc, waylandsink)
- `weston`
- `cam-server`
- `sh` (POSIX shell)
