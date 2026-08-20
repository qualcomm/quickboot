#!/bin/bash
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#
# Generated with assistance from: Claude Sonnet 4.5 (Anthropic) via Cline
#
# install.sh — Combined QuickBoot subsystem + demo-app installer.
#
# Usage:
#   sudo ./install.sh <subsystem>
#
# Subsystems:
#   all      Install quickboot-audio, quickboot-camera, quickboot-display,
#            qcom-audio-chime (demo), qcom-camera-preview (demo)
#   audio    Install quickboot-audio + qcom-audio-chime (demo)
#   camera   Install quickboot-camera + qcom-camera-preview (demo)
#   display  Install quickboot-display (no demo app)
#
# Note: Demo-app service files are installed but NOT auto-enabled.
#       A hint is printed at the end to let the user enable them manually.
#
# Environment overrides:
#   PREFIX       Installation prefix          (default: /usr)
#   BINDIR       Binary directory             (default: $PREFIX/bin)
#   DATADIR      Data directory               (default: $PREFIX/share)
#   SYSTEMD_DIR  systemd system unit dir      (default: /lib/systemd/system)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBSYSTEM="${1:-}"

PREFIX="${PREFIX:-/usr}"
BINDIR="${BINDIR:-${PREFIX}/bin}"
DATADIR="${DATADIR:-${PREFIX}/share}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/lib/systemd/system}"

# ── Help text ─────────────────────────────────────────────────────────────────
print_help() {
    cat <<EOF
Usage: sudo ./install.sh <subsystem>

Subsystems:
  all      Install quickboot-audio, quickboot-camera, quickboot-display,
           qcom-audio-chime (demo), qcom-camera-preview (demo)
  audio    Install quickboot-audio + qcom-audio-chime (demo)
  camera   Install quickboot-camera + qcom-camera-preview (demo)
  display  Install quickboot-display (no demo app)

Examples:
  sudo ./install.sh all
  sudo ./install.sh audio
  sudo ./install.sh camera
  sudo ./install.sh display

Note: Demo-app service files are installed but NOT auto-enabled.
      The installer prints the 'systemctl enable' command at the end.

Environment overrides:
  PREFIX       Installation prefix          (default: /usr)
  BINDIR       Binary directory             (default: \$PREFIX/bin)
  DATADIR      Data directory               (default: \$PREFIX/share)
  SYSTEMD_DIR  systemd system unit dir      (default: /lib/systemd/system)
EOF
}

if [ -z "$SUBSYSTEM" ]; then
    print_help
    exit 0
fi

# ── Root check ────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo "Error: Run as root (sudo ./install.sh <subsystem>)"
    exit 1
fi

# Tracks which demo-app services were installed (for the hint at the end)
DEMO_SERVICES=""

echo "====================================================="
echo "     QuickBoot Runtime Installer (Combined)          "
echo "====================================================="
echo "Subsystem : ${SUBSYSTEM}"
echo "BINDIR    : ${BINDIR}"
echo "DATADIR   : ${DATADIR}"
echo "SYSTEMD   : ${SYSTEMD_DIR}"
echo ""

# Remount the filesystem containing /usr only when it is read-only.
USR_MOUNT="$(findmnt -n -o TARGET -T /usr)"
if findmnt -n -o OPTIONS "$USR_MOUNT" | grep -qw ro; then
    mount -o remount,rw "$USR_MOUNT"
fi

# ── Ensure target directories exist ──────────────────────────────────────────
mkdir -p /etc/modules-load.d
mkdir -p /etc/udev/rules.d
mkdir -p /etc/systemd/system
mkdir -p /usr/bin

# ── Helper: install a file with given mode ────────────────────────────────────
install_file() {
    local src="$1"
    local dst_dir="$2"
    local mode="$3"
    echo "  $(basename "$src")  ->  ${dst_dir}/"
    mkdir -p "${dst_dir}"
    install -m "${mode}" "${src}" "${dst_dir}/"
}

# ── quickboot-display ─────────────────────────────────────────────────────────
install_quickboot_display() {
    echo ""
    echo "--- quickboot-display ---"
    DISP="$SCRIPT_DIR/quickboot-display/files"

    install -m 0644 "$DISP/qcom-display.conf"  /etc/modules-load.d/qcom-display.conf
    install -m 0644 "$DISP/03-drm.rules"       /etc/udev/rules.d/03-drm.rules
    install -m 0644 "$DISP/weston.service"     /etc/systemd/system/weston.service
    install -m 0644 "$DISP/weston.socket"      /etc/systemd/system/weston.socket
}

# ── quickboot-camera ──────────────────────────────────────────────────────────
install_quickboot_camera() {
    echo ""
    echo "--- quickboot-camera ---"
    CAM="$SCRIPT_DIR/quickboot-camera/files"

    install -m 0644 "$CAM/qcom-camera.conf"        /etc/modules-load.d/qcom-camera.conf
    install -m 0644 "$CAM/02-cam-server.rules"      /etc/udev/rules.d/02-cam-server.rules
    install -m 0644 "$CAM/cam-server.service"       /etc/systemd/system/cam-server.service
    install -m 0755 "$CAM/camx-set-vendor-dtbo.sh"  /usr/bin/camx-set-vendor-dtbo.sh
    install -m 0755 "$CAM/camera-sensors-prune.sh"  /usr/bin/camera-sensors-prune.sh

    echo "--- Run the camera configuration scripts ---"
    sh /usr/bin/camx-set-vendor-dtbo.sh
    sh /usr/bin/camera-sensors-prune.sh
}

# ── quickboot-audio ───────────────────────────────────────────────────────────
install_quickboot_audio() {
    echo ""
    echo "--- quickboot-audio ---"
    AUD="$SCRIPT_DIR/quickboot-audio/files"

    install -m 0644 "$AUD/qcom-audio.conf"  /etc/modules-load.d/qcom-audio.conf
}

# ── qcom-audio-chime (demo app) ───────────────────────────────────────────────
# Files are installed; service is NOT auto-enabled.
install_qcom_audio_chime() {
    echo ""
    echo "--- qcom-audio-chime (demo app) ---"
    AUDIO_DIR="$SCRIPT_DIR/qcom-audio-chime/files"

    install_file "${AUDIO_DIR}/audio-chime"         "${BINDIR}"         "0755"
    install_file "${AUDIO_DIR}/sample-3s.wav"       "${DATADIR}/sounds" "0644"
    install_file "${AUDIO_DIR}/audio-chime.service" "${SYSTEMD_DIR}"    "0644"

    DEMO_SERVICES="${DEMO_SERVICES} audio-chime.service"
}

# ── qcom-camera-preview (demo app) ────────────────────────────────────────────
# Files are installed; service is NOT auto-enabled.
install_qcom_camera_preview() {
    echo ""
    echo "--- qcom-camera-preview (demo app) ---"
    CAM_DIR="$SCRIPT_DIR/qcom-camera-preview/files"

    install_file "${CAM_DIR}/camera-preview"         "${BINDIR}"      "0755"
    install_file "${CAM_DIR}/camera-preview.service" "${SYSTEMD_DIR}" "0644"

    DEMO_SERVICES="${DEMO_SERVICES} camera-preview.service"
}

# ── Select subsystems and demo apps based on argument ─────────────────────────
SUBSYSTEM_SERVICES=""

case "$SUBSYSTEM" in
    all)
        install_quickboot_display
        install_quickboot_camera
        install_quickboot_audio
        install_qcom_audio_chime
        install_qcom_camera_preview
        SUBSYSTEM_SERVICES="weston.socket weston.service cam-server.service"
        ;;
    audio)
        install_quickboot_audio
        install_qcom_audio_chime
        SUBSYSTEM_SERVICES=""
        ;;
    camera)
        install_quickboot_camera
        install_qcom_camera_preview
        SUBSYSTEM_SERVICES="cam-server.service"
        ;;
    display)
        install_quickboot_display
        SUBSYSTEM_SERVICES="weston.socket weston.service"
        ;;
    *)
        echo "Error: Unknown subsystem '${SUBSYSTEM}'"
        echo ""
        print_help
        exit 1
        ;;
esac

# Restore labels on the paths modified by the installer.
if command -v restorecon >/dev/null 2>&1 && selinuxenabled 2>/dev/null; then
    restorecon -RF /usr/bin /etc/modules-load.d /etc/udev/rules.d \
        /etc/systemd/system "$BINDIR" "$DATADIR" "$SYSTEMD_DIR"
fi

# ── Reload systemd and enable subsystem services ─────────────────────────────
echo ""
echo "--- Reloading systemd daemon ---"
systemctl daemon-reload

if [ -n "$SUBSYSTEM_SERVICES" ]; then
    echo "--- Enabling subsystem services ---"
    for svc in $SUBSYSTEM_SERVICES; do
        systemctl enable "$svc"
    done
fi

echo "--- Reloading udev rules ---"
udevadm control --reload-rules
udevadm trigger

sync
echo ""
echo "====================================================="
echo "  Installation complete."
echo "  Reboot or restart affected services to apply."
echo "====================================================="

# ── Hint: how to enable demo-app services manually ───────────────────────────
if [ -n "$DEMO_SERVICES" ]; then
    echo ""
    echo "-----------------------------------------------------"
    echo "  Demo app(s) installed but NOT auto-enabled."
    echo "  To enable, run:"
    for svc in $DEMO_SERVICES; do
        echo "    sudo systemctl enable ${svc}"
    done
    echo "-----------------------------------------------------"
fi
