class server (
	$hostname                    = '',
	$locale_default              = 'en_US.UTF-8 UTF-8',
	$locale_available            = ['en_US.UTF-8 UTF-8'],
	$timezone                    = 'America/New_York',
	$cron_env                    = ['MAILTO=root'],
	$ntp_servers                 = [],
	$logrotate                   = true,
	$packages                    = [],
	$users                       = {},
	$security_updates            = true,
) inherits server::params{

	class { 'locales':
	  default_value  => $locale_default,
	  available      => $locale_available,
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
		hostname => $hostname
	}

	if !empty($ntp_servers) {
		class { '::ntp':
		  servers => $ntp_servers,
		}
	}

	class { 'apt':
	  always_apt_update    => false,
	  disable_keys         => undef,
	  purge_sources_list   => true,
	  purge_sources_list_d => true,
	}

	apt::source { 'debian':
	  location          => 'http://ftp.us.debian.org/debian/',
	  release           => 'wheezy',
	  repos             => 'main non-free contrib',
	  include_src       => true
	}

	apt::source { 'updates':
	  location          => 'http://ftp.us.debian.org/debian/',
	  release           => 'wheezy-updates',
	  repos             => 'main non-free contrib',
	  include_src       => true
	}

	apt::source { 'security':
	  location          => 'http://security.debian.org/',
	  release           => 'wheezy/updates',
	  repos             => 'main non-free contrib',
	  include_src       => true
	}

	if(str2bool($security_updates)){
		class { 'server::security_updates': }
	}

	if(str2bool($logrotate)){
		class { 'logrotate': }
	}

	if !empty($packages) {
		package { $packages:
			ensure => installed,
		}	
	}

	if !empty($users) {

		$defaults = {
			key => '',
			key_name => '',
			password => false,
			groups => [],
			shell => false,
		}
	}
}