class server::php(
	$phpmyadmin_enabled = true,
) {
	
	package { "php5":
	    ensure => "installed"
	}

	package { "php5-fpm":
	    ensure => "installed"
	}

	service { 'php5-fpm':
		ensure     => running,
		hasstatus  => true,
		hasrestart => true,
		enable     => true,
	}

	if str2bool($phpmyadmin_enabled) {

		package { "phpmyadmin":
		    ensure => "installed"
		}

		server::webserver::site { 'sqladmin':
			name => 'sqladmin',
			docroot => '/usr/share/phpmyadmin',
			docroot_owner => 'sqladmin',
			docroot_group => 'sqladmin',
		}
	}
}