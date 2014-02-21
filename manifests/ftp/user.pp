define server::ftp::user(
	$user_exist = false,
	$user       = false,
	$group      = false,
	$password   = '',
	$homedir    = '',
) {

	if $user == false {
		$real_user = $name
	}else {
		$real_user = $user
	}

	if $group == false {
		$real_group = $name
	}else {
		$real_group = $group
	}

	if !$user_exist {
		group { "Add ${group} group for FTP":
			name => $group,
			ensure => 'present',
		}

		user { "Add ${user} user for FTP":
		   name => $user,
		   home => false,
		   shell => false,
		   gid => $group,
		   ensure => 'present',
		   require => Group["Add ${group} group for FTP"],
		}
	}

	$uid = get_uid($real_user)
	$gid = get_uid($real_group)
	$real_password = mysql_password($password)

	$sql_insert_user = template("server/ftp/proftpd/sql/insert_user.sql.erb")
    $sql_select_user = template("server/ftp/proftpd/sql/select_user.sql.erb")

    file { "Create insert_ftp_user_${name}.sql":
    	path => "/tmp/insert_ftp_user_${name}.sql",
		ensure  => file,
		content => $sql_insert_user,
	}

	file { "Create select_ftp_user_${name}.sql":
		path => "/tmp/select_ftp_user_${name}.sql",
		ensure  => file,
		content => $sql_select_user,
	}

    $command_insert = "/usr/bin/mysql -u ${server::ftp::mod_mysql_user} -p${server::ftp::mod_mysql_password} ${server::ftp::mod_mysql_db} < /tmp/insert_ftp_user_${name}.sql"
    $command_check = "/usr/bin/mysql -u ${server::ftp::mod_mysql_user} -p${server::ftp::mod_mysql_password} ${server::ftp::mod_mysql_db} < /tmp/select_ftp_user_${name}.sql | grep -c ${name}"

    exec { $command_insert:
	    unless  => $command_check,
	    require => [
	    	File["/tmp/select_ftp_user_${name}.sql"],
	    	File["/tmp/insert_ftp_user_${name}.sql"],
	    ],
	    notify => Service["proftpd"]
	}

}