class server::webserver::apache2::params {
	
	if($::fqdn) {
		$servername = $::fqdn
	} else {
		$servername = $::hostname
	} 
    $user             = 'www-data'
	$group            = 'www-data'
	$apache_name      = 'apache2'
	$httpd_dir        = '/etc/apache2'
	$conf_dir         = $httpd_dir
	$confd_dir        = "${httpd_dir}/conf.d"
	$mod_dir          = "${httpd_dir}/mods-available"
	$mod_enable_dir   = "${httpd_dir}/mods-enabled"
	$vhost_dir        = "${httpd_dir}/sites-available"
	$vhost_enable_dir = "${httpd_dir}/sites-enabled"
	$conf_file        = 'apache2.conf'
	$ports_file       = "${conf_dir}/ports.conf"
	$logroot          = '/var/log/apache2'
	$lib_path         = '/usr/lib/apache2/modules'
	$mpm_module       = 'worker'
	$dev_packages     = ['libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev']
	$default_ssl_cert = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
	$default_ssl_key  = '/etc/ssl/private/ssl-cert-snakeoil.key'
	$ssl_certs_dir    = '/etc/ssl/certs'
	$passenger_root   = '/usr'
	$passenger_ruby   = '/usr/bin/ruby'
	$suphp_addhandler  = 'x-httpd-php'
	$suphp_engine      = 'off'
	$suphp_configpath  = '/etc/php5/apache2'
	$mod_packages     = {
	  'auth_kerb'   => 'libapache2-mod-auth-kerb',
	  'authnz_ldap' => 'libapache2-mod-authz-ldap',
	  'fastcgi'     => 'libapache2-mod-fastcgi',
	  'fcgid'       => 'libapache2-mod-fcgid',
	  'passenger'   => 'libapache2-mod-passenger',
	  'perl'        => 'libapache2-mod-perl2',
	  'php5'        => 'libapache2-mod-php5',
	  'proxy_html'  => 'libapache2-mod-proxy-html',
	  'python'      => 'libapache2-mod-python',
	  'wsgi'        => 'libapache2-mod-wsgi',
	  'dav_svn'     => 'libapache2-svn',
	  'suphp'       => 'libapache2-mod-suphp',
	  'xsendfile'   => 'libapache2-mod-xsendfile',
	}
	$mod_libs         = {
	  'php5' => 'libphp5.so',
	}
	$conf_template     = 'apache/httpd.conf.erb'
	$keepalive         = 'Off'
	$keepalive_timeout = 15
	$fastcgi_lib_path  = '/var/lib/apache2/fastcgi'
	
}