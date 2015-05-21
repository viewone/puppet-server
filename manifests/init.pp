class server (
	$hostname                    = '',
	$default_locale              = 'en_US.UTF-8 UTF-8',
	$locales                     = ['en_US.UTF-8 UTF-8'],
	$timezone                    = 'America/New_York',
	$cron_env                    = ['MAILTO=root'],
	$ntp_servers                 = [],
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
		hostname => $hostname
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
		sources.list => true,
		sources.list.d => true,
		preferences.list => true,
		preferences.list.d => true,
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