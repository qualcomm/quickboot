# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

project('qcom-audio-chime', version : '1.0',
  meson_version : '>= 0.56.0',
  default_options : ['warning_level=1'])

# -----------------------------------------------------------------------
# Directories
# -----------------------------------------------------------------------
prefix      = get_option('prefix')
bindir      = prefix / get_option('bindir')
datadir     = prefix / get_option('datadir')
systemd_dir = get_option('systemd_system_unit_dir')

# Fallback if not passed explicitly (e.g. standalone meson build)
if systemd_dir == ''
  systemd_dir = prefix / 'lib' / 'systemd' / 'system'
endif

# -----------------------------------------------------------------------
# Install audio-chime script  →  <prefix>/bin/audio-chime
# -----------------------------------------------------------------------
install_data(
  'files/audio-chime',
  install_dir  : bindir,
  install_mode : 'rwxr-xr-x',
)

# -----------------------------------------------------------------------
# Install boot chime WAV file  →  <prefix>/share/sounds/sample-3s.wav
# -----------------------------------------------------------------------
install_data(
  'files/sample-3s.wav',
  install_dir  : datadir / 'sounds',
  install_mode : 'rw-r--r--',
)

# -----------------------------------------------------------------------
# Install systemd service unit  →  <systemd_dir>/audio-chime.service
#
# The service file uses hardcoded paths (/usr/bin, /usr/share) and
# requires no substitution at build time.
# -----------------------------------------------------------------------
install_data(
  'files/audio-chime.service',
  install_dir  : systemd_dir,
  install_mode : 'rw-r--r--',
)

# NOTE: Do NOT add a post-install systemctl hook here.
# In a Yocto / cross-build the install step runs inside a fakeroot
# sandbox with no live systemd.  Service enabling is handled by the
# package manager or image recipe (e.g. SYSTEMD_AUTO_ENABLE in BitBake).
