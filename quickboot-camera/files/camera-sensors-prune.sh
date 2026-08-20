#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#
# Camera-HAL initialization incurs a ~1 s delay scanning all sensor module bins
# under /usr/lib/camx/lemans/camera.
#
# This script reduces that delay by moving sensor modules not required for the
# IQ-9075 EVK to a backup directory, leaving only the relevant bins for HAL discovery.
#
# Idempotent: safe to run more than once. If the modules have already been pruned
# (none left under the camera dir) the script exits without error, so re-running
# install.sh does not abort under 'set -e'.

CAMERA_DIR="/usr/lib/camx/lemans/camera"
BACKUP_DIR="/data/sensors-to-remove"
KEEP_GLOB="com.qti.sensormodule.cmk_imx577_rb8_csi*"

mkdir -p "$BACKUP_DIR"

# Nothing to do if there are no sensor modules left to prune.
if ! ls "$CAMERA_DIR"/com.qti.sensormodule.* >/dev/null 2>&1; then
    echo "camera-sensors-prune: no sensor modules under $CAMERA_DIR, already pruned"
    exit 0
fi

# Move all sensor modules aside, then restore the ones this board needs.
mv "$CAMERA_DIR"/com.qti.sensormodule.* "$BACKUP_DIR"/
if ls "$BACKUP_DIR"/$KEEP_GLOB >/dev/null 2>&1; then
    mv "$BACKUP_DIR"/$KEEP_GLOB "$CAMERA_DIR"/
else
    echo "camera-sensors-prune: warning: no modules matched '$KEEP_GLOB' to keep"
fi
