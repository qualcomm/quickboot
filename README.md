# QuickBoot


QuickBoot is an early-boot optimization package for Qualcomm platforms that dramatically
reduces time-to-first-frame (TTFF) for display, camera, and audio subsystems — a critical
KPI for industrial, and consumer IoT devices where perceived responsiveness at
power-on directly impacts user experience and product differentiation.

By combining deterministic kernel module pre-loading, hardware-event-driven service activation,
and aggressive removal of implicit systemd ordering barriers, QuickBoot enables subsystems to
reach a ready state in parallel with the rest of the boot sequence, rather than waiting
for the full userspace initialization chain to complete.

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
curl -L https://github.com/qualcomm/quickboot/archive/refs/heads/main.zip -o quickboot.zip
unzip quickboot.zip
cd quickboot-main
chmod +x install.sh
./install.sh all
```

The script copies all configs, udev rules, systemd units, and scripts to their correct
system paths, then reloads `systemd` and `udev` automatically.

## Yocto Integration

This project can be pulled directly into a Yocto build by composing a `.bb` recipe
that fetches from this repository. Example recipe snippet:

```bitbake
inherit meson systemd

SRC_URI = "git://github.com/qualcomm/quickboot.git;protocol=https;branch=main"
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
BSD 3-Clause Clear License — see [LICENSE](LICENSE.txt) for details.
