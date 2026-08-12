project('quickboot-audio', version : '1.0')

sysconfdir = get_option('prefix') / get_option('sysconfdir')

install_data(
    'files/audio-modules.conf',
    install_dir  : sysconfdir / 'modules-load.d',
    install_mode : 'rw-r--r--',
    )