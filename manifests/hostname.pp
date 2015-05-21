class server::hostname( $hostname = '', $hosts = {}) {

	if empty($hostname) {
		warning( 'You have to specify hostname' )
	}

	file { "/etc/hosts":
		ensure => present,
		content => template('server/hosts.erb'),
	}

	file { 'hostname':
	    path    => '/etc/hostname',
	    ensure  => present,
	    owner   => 'root',
	    group   => 'root',
	    mode    => 0644,
	    content => $hostname,
	    before => Exec['/etc/init.d/hostname.sh']
	}

	exec { '/etc/init.d/hostname.sh':
	    require => File['/etc/hostname'],
	    refreshonly => true
	}
}