#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#
# Run automatically by install.sh when installing the camera subsystem, and safe
# to run manually on the device during first boot for the camera to work across
# subsequent builds.
#
# Initializes the required EFI variable settings for the camera (VendorDtbOverlays)
#
# Idempotent: writing the same EFI variable value repeatedly is harmless, so this
# is safe to re-run (e.g. from install.sh under 'set -e').

VAR="882f8c2b-9646-435f-8de5-f208ff80c1bd-VendorDtbOverlays"

if ! command -v efivar >/dev/null 2>&1; then
    echo "camx-set-vendor-dtbo: efivar not found, cannot set $VAR" >&2
    exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
printf 'camx' > "$TMP"

efivar -n "$VAR" -w -f "$TMP"
efivar -n "$VAR" -p

