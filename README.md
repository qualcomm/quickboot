# QuickBoot

Early boot optimization package for Qualcomm platforms.
Installs udev rules, kernel module lists, and systemd units to minimize
time-to-first-frame for display, camera, and audio subsystems.

## How It Works

1. **Module pre-loading** — `modules-load.d` configs load kernel modules in dependency order
   via `systemd-modules-load.service`, bypassing the slow, non-deterministic udev coldplug path.
2. **Event-driven activation** — udev rules fire each service the instant its device node appears
   (`controlC0` → PipeWire, `video0` → cam-server, `card0` → Weston), eliminating udev detection delays.
3. **`DefaultDependencies=no`** — removes implicit ordering after `sysinit.target`/`basic.target`,
   letting services start in parallel with the rest of boot as soon as hardware is ready.

## Subsystems
- **display** — Weston compositor, DRM udev rules, display kernel modules
- **camera**  — cam-server, camera preview app, camera udev rules
- **audio**   — PipeWire service, audio chime app, audio udev rules

## Runtime Install (on device)

Clone the repo on the device and run the installer script directly — no build tools needed:

```bash
git clone https://github.com/qualcomm/quickboot.git
cd quickboot
sudo ./install.sh
```

The script copies all configs, udev rules, systemd units, and scripts to their correct
system paths, then reloads `systemd` and `udev` automatically.

## Yocto Integration

This project uses one top-level Meson build for all subsystems. It can be pulled
directly into a Yocto build with a single `.bb` recipe. Example recipe snippet:

```bitbake
inherit meson systemd

SRC_URI = "git://github.com/qualcomm/quickboot.git;protocol=https;branch=main"
SRCREV  = "<commit-hash>"

S = "${UNPACKDIR}/git"

EXTRA_OEMESON += "-Dsystemd_system_unitdir=${systemd_system_unitdir}"

FILES:${PN} = " \
    ${sysconfdir}/modules-load.d/ \
    ${sysconfdir}/udev/rules.d/ \
    ${systemd_system_unitdir}/ \
    ${bindir}/camx-set-vendor-dtbo.sh \
    ${bindir}/camera-sensors-prune.sh \
"
```

The recipe may split display, camera, and audio into separate output packages
while keeping a single source tree and Meson project.

## Authors
- Chitti Babu Theegala — `ctheegal@qti.qualcomm.com`, Qualcomm Technologies, Inc.
- Wen Wen Fu — `wenwfu@qti.qualcomm.com`, Qualcomm Technologies, Inc.
- Tarun Balaji Nidiganti — `tnidiganti@qti.qualcomm.com`, Qualcomm Technologies, Inc.

## License
MIT — see [LICENSE](LICENSE.txt) for details.
