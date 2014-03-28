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
	$apache_default_mods         = true,
	$apache_default_vhost        = true,
	$apache_default_ssl_vhost    = false,
	$apache_default_ssl_cert     = $server::params::default_ssl_cert,
	$apache_default_ssl_key      = $server::params::default_ssl_key,
	$apache_default_ssl_chain    = undef,
	$apache_default_ssl_ca       = undef,
	$apache_default_ssl_crl_path = undef,
	$apache_default_ssl_crl      = undef,
	$apache_service_enable       = true,
	$apache_service_ensure       = 'running',
	$apache_purge_configs        = true,
	$apache_purge_vdir           = false,
	$apache_serveradmin          = 'root@localhost',
	$apache_sendfile             = 'On',
	$apache_error_documents      = false,
	$apache_timeout              = '120',
	$apache_httpd_dir            = $server::params::httpd_dir,
	$apache_confd_dir            = $server::params::confd_dir,
	$apache_vhost_dir            = $server::params::vhost_dir,
	$apache_vhost_enable_dir     = $server::params::vhost_enable_dir,
	$apache_mod_dir              = $server::params::mod_dir,
	$apache_mod_enable_dir       = $server::params::mod_enable_dir,
	$apache_mpm_module           = $server::params::mpm_module,
	$apache_conf_template        = $server::params::conf_template,
	$apache_servername           = $server::params::servername,
	$apache_manage_user          = true,
	$apache_manage_group         = true,
	$apache_user                 = $server::params::user,
	$apache_group                = $server::params::group,
	$apache_keepalive            = $server::params::keepalive,
	$apache_keepalive_timeout    = $server::params::keepalive_timeout,
	$apache_logroot              = $server::params::logroot,
	$apache_ports_file           = $server::params::ports_file,
	$apache_server_tokens        = 'OS',
	$apache_server_signature     = 'On',
	$apache_package_ensure       = 'installed',
	$php_enabled                 = true,
	$phpmyadmin_enabled          = true,
	$mysql_enabled               = true,
	$mysql_client_enabled        = true,
	$mysql_root_password         = '',
	$ftp_enabled                 = true,
	$ftp_user                    = 'proftpd',
	$ftp_group                   = 'proftpd',
	$ftp_mod_mysql_enabled       = true,
	$ftp_mod_mysql_db            = 'proftpd',
	$ftp_mod_mysql_user          = 'proftpd',
	$ftp_mod_mysql_password      = '',
) inherits server::params{

	class { 'locales':
	  default_value  => $locale_default,
	  available      => $locale_available,
	}

	class { 'timezone':
	  timezone => $timezone,
	}

	cron { 'enviroment':
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
	  repos             => 'main',
	  include_src       => true
	}

	apt::source { 'updates':
	  location          => 'http://ftp.us.debian.org/debian/',
	  release           => 'wheezy-updates',
	  repos             => 'main',
	  include_src       => true
	}

	apt::source { 'security':
	  location          => 'http://security.debian.org/',
	  release           => 'wheezy/updates',
	  repos             => 'main',
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

		create_resources(suser, $users, $defaults)
	}

	class { 'server::webserver':
		default_mods         => $apache_default_mods,
	    default_vhost        => $apache_default_vhost,
	    default_ssl_vhost    => $apache_default_ssl_vhost,
	    default_ssl_cert     => $apache_default_ssl_cert,
	    default_ssl_key      => $apache_default_ssl_key,
	    default_ssl_chain    => $apache_default_ssl_chain,
	    default_ssl_ca       => $apache_default_ssl_ca,
	    default_ssl_crl_path => $apache_default_ssl_crl_path,
	    default_ssl_crl      => $apache_default_ssl_crl,
	    service_enable       => $apache_service_enable,
	    service_ensure       => $apache_service_ensure,
	    purge_configs        => $apache_purge_configs,
	    purge_vdir           => $apache_purge_vdir,
	    serveradmin          => $apache_serveradmin,
	    sendfile             => $apache_sendfile,
	    error_documents      => $apache_error_documents,
	    timeout              => $apache_timeout,
	    httpd_dir            => $apache_httpd_dir,
	    confd_dir            => $apache_confd_dir,
	    vhost_dir            => $apache_vhost_dir,
	    vhost_enable_dir     => $apache_vhost_enable_dir,
	    mod_dir              => $apache_mod_dir,
	    mod_enable_dir       => $apache_mod_enable_dir,
	    mpm_module           => $apache_mpm_module,
	    conf_template        => $apache_conf_template,
	    servername           => $apache_servername,
	    manage_user          => $apache_manage_user,
	    manage_group         => $apache_manage_group,
	    user                 => $apache_user,
	    group                => $apache_group,
	    keepalive            => $apache_keepalive,
	    keepalive_timeout    => $apache_keepalive_timeout,
	    logroot              => $apache_logroot,
	    ports_file           => $apache_ports_file,
	    server_tokens        => $apache_server_tokens,
	    server_signature     => $apache_server_signature,
	    package_ensure       => $apache_package_ensure,
	}

	# if(str2bool($php_enabled)){
	# 	class { 'server::php': 
	# 		phpmyadmin_enabled => $phpmyadmin_enabled
	# 	}
	# }

	# if(str2bool($mysql_enabled)){

	# 	class { 'mysql::server':
	# 		root_password    => $mysql_root_password,
	# 	}

	# 	if(str2bool($mysql_client_enabled)){
	# 		class { 'mysql::client': }
	# 	}

	# 	if(str2bool($php_enabled)){
	# 		class { 'mysql::bindings':
	# 			php_enable => true,
	# 		}
	# 	}
	# }

	# if(str2bool($ftp_enabled)){
	# 	class { 'server::ftp': 
	# 		ftp_user           => $ftp_user,
	# 		ftp_group          => $ftp_group,
	# 		mod_mysql_enabled  => $ftp_mod_mysql_enabled,
	# 		mod_mysql_db       => $ftp_mod_mysql_db,
	# 		mod_mysql_user     => $ftp_mod_mysql_user,
	# 		mod_mysql_password => $ftp_mod_mysql_password,
	# 	}
	# }
}

define suser ($key, $key_name, $password, $groups, $shell) {
	user { $name :
		name => $name,
		ensure => 'present',
		managehome => true,
		password => $password,
		groups => $groups,
		shell => $shell,
	}

	if !empty($key) {

		ssh_authorized_key { $name:
		    ensure => present,
		    key    => $key,
		    type   => 'ssh-rsa',
		    name   => $key_name,
		    user   => $name,
		    require => User[$name],
		}
	}
}
