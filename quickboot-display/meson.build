project('quickboot-display', version : '1.0')

sysconfdir = get_option('prefix') / get_option('sysconfdir')
unitdir    = sysconfdir / 'systemd' / 'system'

install_data(
    'files/03-drm.rules',
    install_dir  : sysconfdir / 'udev' / 'rules.d',
    install_mode : 'rw-r--r--',
    )

install_data(
    'files/display-modules.conf',
    install_dir  : sysconfdir / 'modules-load.d',
    install_mode : 'rw-r--r--',
    )

install_data(
    'files/weston.service',
    'files/weston.socket',
    install_dir  : unitdir,
    install_mode : 'rw-r--r--',
    )
