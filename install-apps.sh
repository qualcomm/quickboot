#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#
# install-apps.sh — Installs and enables qcom-audio-chime and
#                   qcom-camera-preview.
#
# Usage:
#   ./install-apps.sh [DESTDIR]
#
# DESTDIR  Optional sysroot prefix (default: empty, installs to live rootfs).
#          Example: ./install-apps.sh /mnt/target
#
# Environment overrides:
#   PREFIX       Installation prefix          (default: /usr)
#   BINDIR       Binary directory             (default: $PREFIX/bin)
#   DATADIR      Data directory               (default: $PREFIX/share)
#   SYSTEMD_DIR  systemd system unit dir      (default: /lib/systemd/system)
#
# Service enabling is done by creating the standard .wants symlinks under
# SYSTEMD_DIR/multi-user.target.wants/ — this works for both sysroot
# staging (cross-build) and live-rootfs installs without requiring a
# running systemd.

set -e

DESTDIR="${1:-}"

PREFIX="${PREFIX:-/usr}"
BINDIR="${BINDIR:-${PREFIX}/bin}"
DATADIR="${DATADIR:-${PREFIX}/share}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/lib/systemd/system}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " QuickBoot Demo Apps Installer"
echo "========================================"
echo "DESTDIR   : ${DESTDIR:-/  (live rootfs)}"
echo "BINDIR    : ${BINDIR}"
echo "DATADIR   : ${DATADIR}"
echo "SYSTEMD   : ${SYSTEMD_DIR}"
echo ""

# Helper: install a single file with given mode
install_file() {
    local src="$1"
    local dst_dir="$2"
    local mode="$3"
    local dst="${DESTDIR}${dst_dir}"

    echo "  $(basename "$src")  ->  ${dst}/"
    mkdir -p "${dst}"
    install -m "${mode}" "${src}" "${dst}/"
}

# Helper: enable a systemd service by creating the .wants symlink.
# This is equivalent to 'systemctl enable <service>' and works inside
# a sysroot without a running systemd instance.
enable_service() {
    local service="$1"
    local wants_dir="${DESTDIR}${SYSTEMD_DIR}/multi-user.target.wants"

    echo "--- Reloading systemd daemon ---"
    systemctl daemon-reload

    echo "  enabling ${service}  ->  ${wants_dir}/"
    mkdir -p "${wants_dir}"
    ln -sf "../${service}" "${wants_dir}/${service}"
}

# -----------------------------------------------------------------------
# qcom-audio-chime
# -----------------------------------------------------------------------
echo "--- qcom-audio-chime ---"
AUDIO_DIR="${SCRIPT_DIR}/qcom-audio-chime/files"

install_file "${AUDIO_DIR}/audio-chime"         "${BINDIR}"         "0755"
install_file "${AUDIO_DIR}/sample-3s.wav"       "${DATADIR}/sounds" "0644"
install_file "${AUDIO_DIR}/audio-chime.service" "${SYSTEMD_DIR}"    "0644"
enable_service "audio-chime.service"
echo ""

# -----------------------------------------------------------------------
# qcom-camera-preview
# -----------------------------------------------------------------------
echo "--- qcom-camera-preview ---"
CAM_DIR="${SCRIPT_DIR}/qcom-camera-preview/files"

install_file "${CAM_DIR}/camera-preview"           "${BINDIR}"      "0755"
install_file "${CAM_DIR}/camera-preview.service"   "${SYSTEMD_DIR}" "0644"
enable_service "camera-preview.service"
echo ""

echo "========================================"
echo " Installation complete."
echo " Both services are enabled for"
echo " multi-user.target."
echo "========================================"
