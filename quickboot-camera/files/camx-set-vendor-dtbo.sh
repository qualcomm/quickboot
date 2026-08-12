#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# ==============================================================================
# DESCRIPTION:
# This script must be executed manually by the user during the first boot for 
# camera to work from subsequent builds on the terminal.
#
# Initializes the required EFI variable settings for the camera (VendorDtbOverlays)

echo -n "camx" > /var/data
efivar -n 882f8c2b-9646-435f-8de5-f208ff80c1bd-VendorDtbOverlays -w -f /var/data
efivar -n 882f8c2b-9646-435f-8de5-f208ff80c1bd-VendorDtbOverlays -p

