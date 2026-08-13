project(
  'quickboot',
  version : '1.0.0',
  license : 'MIT',
)

sysconfdir = get_option('sysconfdir')
bindir = get_option('bindir')

systemd_system_unitdir = get_option('systemd_system_unitdir')
if systemd_system_unitdir == ''
  systemd_dep = dependency('systemd', required : false)
  if systemd_dep.found()
    systemd_system_unitdir = systemd_dep.get_variable(
      pkgconfig : 'systemdsystemunitdir',
    )
  else
    systemd_system_unitdir = join_paths(
      get_option('prefix'),
      'lib/systemd/system',
    )
  endif
endif

install_data(
  'quickboot-audio/files/qcom-audio.conf',
  install_dir : join_paths(sysconfdir, 'modules-load.d'),
)

install_data(
  'quickboot-camera/files/qcom-camera.conf',
  install_dir : join_paths(sysconfdir, 'modules-load.d'),
)

install_data(
  'quickboot-camera/files/02-cam-server.rules',
  install_dir : join_paths(sysconfdir, 'udev/rules.d'),
)

install_data(
  'quickboot-camera/files/cam-server.service',
  install_dir : systemd_system_unitdir,
)

install_data(
  'quickboot-camera/files/camx-set-vendor-dtbo.sh',
  'quickboot-camera/files/camera-sensors-prune.sh',
  install_dir : bindir,
  install_mode : 'rwxr-xr-x',
)

install_data(
  'quickboot-display/files/qcom-display.conf',
  install_dir : join_paths(sysconfdir, 'modules-load.d'),
)

install_data(
  'quickboot-display/files/03-drm.rules',
  install_dir : join_paths(sysconfdir, 'udev/rules.d'),
)

install_data(
  'quickboot-display/files/weston.service',
  'quickboot-display/files/weston.socket',
  install_dir : systemd_system_unitdir,
)
