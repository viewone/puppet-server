class server::security_updates {

    package { 'cron-apt':
        ensure => installed,
    }

    file { 'action.d/0-update':
        path    => '/etc/cron-apt/action.d/0-update',
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => 'update -o quiet=2',
        require => Package['cron-apt']
    }

    file { 'action.d/3-download':
        path    => '/etc/cron-apt/action.d/3-download',
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => "autoclean -y \nupgrade -d -y -o APT::Get::Show-Upgraded=true\n",
        require => Package['cron-apt']
    }

    file { 'action.d/5-security':
        path    => '/etc/cron-apt/action.d/5-security',
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => 'upgrade -y -o APT::Get::Show-Upgraded=true',
        require => Package['cron-apt']
    }

    file { 'config.d/5-security':
        path    => '/etc/cron-apt/config.d/5-security',
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => 'OPTIONS="-o quiet=1 --no-list-cleanup -o Dir::Etc::SourceList=/etc/apt/sources.list.d/security.list -o Dir::Etc::SourceParts=\"/dev/null\""',
        require => Package['cron-apt']
    }

    file { 'cron.d/cron-apt':
        path    => '/etc/cron.d/cron-apt',
        ensure  => absent,
        require => Package['cron-apt']
    }

    cron { 'cron-apt':
      command => "test -x /usr/sbin/cron-apt && /usr/sbin/cron-apt",
      user    => root,
      hour    => 4,
      minute  => 0
    }

}