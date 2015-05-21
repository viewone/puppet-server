class server (
    $default_locale              = 'en_US.UTF-8 UTF-8',
    $locales                     = ['en_US.UTF-8 UTF-8'],
    $timezone                    = 'America/New_York',
    $cron_env                    = ['MAILTO=root'],
    $ntp_servers                 = [],
    $hostname                    = '',
    $hosts                       = {},
    $logrotate                   = true,
    $packages                    = [],
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

    apt::source { 'debian':
      location          => 'http://ftp.us.debian.org/debian/',
      release           => 'wheezy',
      repos             => 'main non-free contrib',
      include           => {
        deb => true,
      }
    }

    apt::source { 'updates':
      location          => 'http://ftp.us.debian.org/debian/',
      release           => 'wheezy-updates',
      repos             => 'main non-free contrib',
      include           => {
        deb => true,
      }
    }

    apt::source { 'security':
      location          => 'http://security.debian.org/',
      release           => 'wheezy/updates',
      repos             => 'main non-free contrib',
      include           => {
        deb => true,
      }
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
}