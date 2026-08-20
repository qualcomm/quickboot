
# Quickboot Camera Optimizations for IQ-9075 EVK

This package provides services, rules, and kernel module configurations to optimize the camera boot time (Time-to-First-Frame) on the IQ-9075 EVK.

## First Boot Setup

Two one-time setup steps are required for the camera to work correctly and optimally:

1. **`camx-set-vendor-dtbo.sh`** — initializes the `VendorDtbOverlays` EFI variable.
2. **`camera-sensors-prune.sh`** — moves sensor module binaries not needed by the
   IQ-9075 EVK out of the camera HAL discovery path to cut ~1 s of scan time.

The combined installer runs both scripts automatically when installing the camera
subsystem:

```bash
./install.sh camera
```

If you need to run them manually on the device (e.g. after a first boot without the
installer), both scripts are installed to `/usr/bin` and are safe to re-run:

```bash
/usr/bin/camx-set-vendor-dtbo.sh
/usr/bin/camera-sensors-prune.sh
```
