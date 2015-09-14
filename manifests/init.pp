class server (
    $default_locale              = 'en_US.UTF-8 UTF-8',
    $locales                     = ['en_US.UTF-8 UTF-8'],
    $timezone                    = 'America/New_York',
    $hostname                    = '',
    $hosts                       = {},
    $sources                     = {},
    $cron_env                    = ['MAILTO=root'],
    $ntp_servers                 = [],
    $logrotate                   = true,
    $packages                    = [],
    $ssh                         = {},
    $firewall                    = {},
    $users                       = {},
    $security_updates            = true,
) inherits server::params{

    class { 'locales':
      default_locale => $default_locale,
      locales        => $locales,
    }

    class { 'timezone':
      timezone => $timezone,
    }

    # Add fake cron only to insert environment variable
    cron { 'environment':
      environment => $cron_env,
      command => 'echo "" > /dev/null',
      minute => '0',
      hour => '0',
      monthday => '1',
      month => '*',
    }

    class { 'server::hostname':
        hostname => $hostname,
        hosts => $hosts,
    }

    if !empty($ntp_servers) {
        class { '::ntp':
          servers => $ntp_servers,
        }
    }

    class { 'ssh':
      storeconfigs_enabled => false,
      server_options => $ssh
    }

    if !empty($users) {

        class { 'apt':
            update => {
                frequency => 'daily',
            },
            purge => {
                'sources.list' => true,
                'sources.list.d' => true,
                'preferences.list' => true,
                'preferences.list.d' => true,
            },
        }

        $sources_default = {
            location => '',
            release => 'wheezy',
            repos => 'main non-free contrib',
            include           => {
                deb => true,
              }
        }

        create_resources(apt::source, $sources, $sources_default)
    }

    if(str2bool($security_updates)){
        class { 'server::security_updates': }
    }

    if !empty($packages) {
        package { $packages:
            ensure => installed,
        }
    }

    if(str2bool($logrotate)){

        logrotate::rule { 'apache2':
          path         => '/var/log/apache/*.log',
          missingok    => true,
          rotate_every => 'week',
          create       => true,
          create_mode  => 664,
          create_owner => www-data,
          create_group => www-data,
          dateext      => true,
          maxage       => 30,
          compress     => true,
          sharedscripts => true,
          postrotate   => '/etc/init.d/apache2 reload > /dev/null',
        }
    }

    if !empty($users) {

        $defaults = {
            uid => '',
            gid => '',
            key => '',
            key_name => '',
            password => false,
            shell => false,
        }

        create_resources(server_user, $users, $defaults)
    }

    if !empty($firewall) {

        include ufw

        exec { 'ufw-reset':
            require => Package['ufw'],
            command => '/usr/sbin/ufw --force reset',
        }

        if !empty($firewall[allow]) {

            $firewall_defaults = {
                proto => 'tcp',
                port => 'all',
                ip => '',
                from => 'any',
                require => Exec['ufw-reset']
            }

            create_resources('::ufw::allow', $firewall[allow], $firewall_defaults)
        }
    }
}