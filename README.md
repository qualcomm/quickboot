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
git clone https://github.com/ctheegal/quickboot.git
cd quickboot
sudo ./install.sh
```

The script copies all configs, udev rules, systemd units, and scripts to their correct
system paths, then reloads `systemd` and `udev` automatically.

## Yocto Integration

This project can be pulled directly into a Yocto build by composing a `.bb` recipe
that fetches from this repository. Example recipe snippet:

```bitbake
inherit meson systemd

SRC_URI = "git://github.com/ctheegal/quickboot.git;protocol=https;branch=main"
SRCREV  = "<commit-hash>"

S = "${UNPACKDIR}/git/quickboot-<subsystem>"

FILES:${PN} = " \
    ${sysconfdir}/modules-load.d/ \
    ${sysconfdir}/udev/rules.d/ \
    ${sysconfdir}/systemd/system/ \
"
```

Each subsystem (`quickboot-display`, `quickboot-camera`, `quickboot-audio`) can be
packaged as a separate recipe pointing to its subdirectory via the `S` variable.

## Authors
- Chitti Babu Theegala — `ctheegal@qti.qualcomm.com`, Qualcomm Technologies, Inc.
- Wen Wen Fu — `wenwfu@qti.qualcomm.com`, Qualcomm Technologies, Inc.
- Tarun Balaji Nidiganti — `tnidiganti@qti.qualcomm.com`, Qualcomm Technologies, Inc.

## License
MIT — see [LICENSE](LICENSE.txt) for details.
