#!/bin/bash
# install.sh
#
# Installs QuickBoot early-boot files directly onto the device at runtime.
# Run from the root of the cloned quickboot repository:
#
#   Option-1 (If 'git' available on the device):
#   git clone https://github.com/qualcomm/quickboot.git
#   cd quickboot
#   sudo ./install.sh
#
#   Option-2:
#   curl -L https://github.com/qualcomm/quickboot/archive/refs/heads/main.zip -o quickboot.zip
#   unzip quickboot.zip
#   cd quickboot-main
#   sudo ./install.sh


set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "====================================================="
echo "         QuickBoot Runtime Installer                 "
echo "====================================================="

if [ "$EUID" -ne 0 ]; then
    echo "Error: Run as root (sudo ./install.sh)"
    exit 1
fi

# ── Ensure target directories exist ──────────────────────────────────────────
mkdir -p /etc/modules-load.d
mkdir -p /etc/udev/rules.d
mkdir -p /etc/systemd/system
mkdir -p /usr/bin

# ── quickboot-display ─────────────────────────────────────────────────────────
echo ""
echo "--- quickboot-display ---"
DISP="$SCRIPT_DIR/quickboot-display/files"

install -m 0644 "$DISP/qcom-display.conf"  /etc/modules-load.d/qcom-display.conf
install -m 0644 "$DISP/03-drm.rules"       /etc/udev/rules.d/03-drm.rules
install -m 0644 "$DISP/weston.service"     /etc/systemd/system/weston.service
install -m 0644 "$DISP/weston.socket"      /etc/systemd/system/weston.socket

# ── quickboot-camera ──────────────────────────────────────────────────────────
echo ""
echo "--- quickboot-camera ---"
CAM="$SCRIPT_DIR/quickboot-camera/files"

install -m 0644 "$CAM/qcom-camera.conf"        /etc/modules-load.d/qcom-camera.conf
install -m 0644 "$CAM/02-cam-server.rules"      /etc/udev/rules.d/02-cam-server.rules
install -m 0644 "$CAM/cam-server.service"       /etc/systemd/system/cam-server.service
install -m 0755 "$CAM/camx-set-vendor-dtbo.sh"  /usr/bin/camx-set-vendor-dtbo.sh
install -m 0755 "$CAM/camera-sensors-prune.sh"  /usr/bin/camera-sensors-prune.sh

# ── quickboot-audio ───────────────────────────────────────────────────────────
echo ""
echo "--- quickboot-audio ---"
AUD="$SCRIPT_DIR/quickboot-audio/files"

install -m 0644 "$AUD/qcom-audio.conf"  /etc/modules-load.d/qcom-audio.conf

# ── Reload systemd and enable services ───────────────────────────────────────
echo ""
echo "--- Reloading systemd daemon ---"
systemctl daemon-reload

echo "--- Enabling services ---"
systemctl enable weston.socket          # socket-activated: starts weston.service on demand
systemctl enable weston.service
systemctl enable cam-server.service

echo "--- Reloading udev rules ---"
udevadm control --reload-rules
udevadm trigger

echo ""
echo "====================================================="
echo "  Installation complete."
echo "  Reboot or restart affected services to apply."
echo "====================================================="
