class server::hostname( $hostname = '' ) {

	if empty($hostname) {
		warning( 'You have to specify hostname' )
	}

	file { 'hostname':
	    path    => '/etc/hostname',
	    ensure  => present,
	    owner   => 'root',
	    group   => 'root',
	    mode    => 0644,
	    content => $hostname,
	    notify => Exec['/etc/init.d/hostname.sh']
	}

	exec { '/etc/init.d/hostname.sh':
	    require => File['/etc/hostname'],
	    refreshonly => true
	}

}