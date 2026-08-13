project('quickboot-camera', version : '1.0')

sysconfdir = get_option('prefix') / get_option('sysconfdir')
bindir     = get_option('bindir')
unitdir    = sysconfdir / 'systemd' / 'system'

install_data(
    'files/02-cam-server.rules',
    install_dir  : sysconfdir / 'udev' / 'rules.d',
    install_mode : 'rw-r--r--',
    )

install_data(
    'files/qcom-camera.conf',
    install_dir  : sysconfdir / 'modules-load.d',
    install_mode : 'rw-r--r--',
    )

install_data(
    'files/cam-server.service',
    install_dir  : unitdir,
    install_mode : 'rw-r--r--',
    )

install_data(
    'files/camx-set-vendor-dtbo.sh',
    install_dir  : bindir,
    install_mode : 'rw-r-xr-x',
    )

install_data(
    'files/camera-sensors-prune.sh',
    install_dir  : bindir,
    install_mode : 'rw-r-xr-x',
    )
