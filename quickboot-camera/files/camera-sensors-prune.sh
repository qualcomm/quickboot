#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#
# Camera-HAL initialization incurs a ~1 s delay scanning all sensor module bins 
# under /usr/lib/camx/lemans/camera. 
#
# This script reduces that delay by moving sensor modules not required for the 
# IQ-9075 EVK to a backup directory, leaving only the relevant bins for HAL discovery.

mkdir /data/sensors-to-remove
mv /usr/lib/camx/lemans/camera/com.qti.sensormodule.* /data/sensors-to-remove
mv /data/sensors-to-remove/com.qti.sensormodule.cmk_imx577_rb8_csi* /usr/lib/camx/lemans/camera/
