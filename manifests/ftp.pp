class server::ftp(
	$ftp_user           = $server::ftp::params::ftp_user,
	$ftp_group          = $server::ftp::params::ftp_group,
	$mod_mysql_enabled  = $server::ftp::params::mod_mysql_enabled,
	$mod_mysql_db       = $server::ftp::params::mod_mysql_db,
	$mod_mysql_user     = $server::ftp::params::mod_mysql_user,
	$mod_mysql_password = '',
) inherits server::ftp::params{


	group { 'Add proftpd group':
		name => $ftp_group,
		ensure => 'present',
	}

	user { 'Add proftpd user':
	   name => $ftp_user,
	   home => false,
	   shell => false,
	   gid => $ftp_group,
	   ensure => 'present',
	   require => Group['Add proftpd group'],
	}

	package { "proftpd-basic":
	    ensure => "installed"
	}

	package { "proftpd-mod-mysql":
	    ensure => "installed"
	}

	service { 'proftpd':
		ensure     => running,
		hasstatus  => true,
		hasrestart => true,
		enable     => true,
	}

	file { "proftpf.conf":
		path    => "/etc/proftpd/proftpd.conf", 
		ensure  => present,
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		content => template("server/ftp/proftpd.conf.erb"),
		notify  => Service[proftpd]
	}

	file { "proftpf/modules.conf":
		path    => "/etc/proftpd/modules.conf", 
		ensure  => present,
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		content => template("server/ftp/proftpd/modules.conf.erb"),
		notify  => Service[proftpd]
	}

	file { "proftpf/sql.conf":
		path    => "/etc/proftpd/sql.conf", 
		ensure  => present,
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		content => template("server/ftp/proftpd/sql.conf.erb"),
		notify  => Service[proftpd]
	}

	$module_path = get_module_path('server')

	mysql::db { $mod_mysql_db:
		user     => $mod_mysql_user,
		password => $mod_mysql_password,
		host     => 'localhost',
		grant    => ['ALL'],
    }

    $sql = "${$module_path}/templates/ftp/proftpd/sql/proftpd.sql"
    $sql_check = "${$module_path}/templates/ftp/proftpd/sql/proftpd_check.sql"
    $proftpd_import = "/usr/bin/mysql -u ${mod_mysql_user} -p${mod_mysql_password} ${mod_mysql_db} < ${sql}"
    $proftpd_check = "/usr/bin/mysql -u ${mod_mysql_user} -p${mod_mysql_password} ${mod_mysql_db} < ${sql_check} | grep -c ftpusers"

    exec { $proftpd_import:
	    require => Mysql::Db[$mod_mysql_db],
	    unless  => $proftpd_check
	}
}