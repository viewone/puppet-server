define server::webserver::site (
  $host           = '',
  $docroot        = '',
  $docroot_prefix = '',
  $docroot_owner  = '',
  $docroot_group  = '',
  $mysql_db       = '',
  $mysql_user     = '',
  $mysql_password = '',
  $mysql_host     = 'localhost',
  $ftp_enabled    = false,
  $ftp_user       = '',
  $ftp_group      = '',
  $ftp_password   = '',
){
  require server::webserver
  require mysql::server

  group { "Add ${name} group":
    name => $name,
    ensure => 'present',
  }

  user { "Add ${name} user":
     name => $name,
     home => false,
     shell => false,
     gid => $name,
     ensure => 'present',
     require => Group["Add ${name} group"],
  }

  if(empty($host)){
    $real_host = "${name}.${fqdn}"
  }else {
    $real_host = $host
  }

  if empty($docroot) {
    if !empty($docroot_prefix) {
      $real_docroot = "/var/www/${docroot_prefix}/${name}"  
    } else {
      $real_docroot = "/var/www/${name}"
    }
  }else {
    $real_docroot = $docroot
  }

  file { "pool-${name}":
      path    => "/etc/php5/fpm/pool.d/${name}.conf", 
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      content => template("server/webserver/site/pool.conf.erb"),
      notify  => Service[php5-fpm]
  }

  if str2bool($ftp_enabled){

    server::ftp::user { $ftp_user:
      user_exist => true,
      password   => $ftp_password,
      homedir    => $real_docroot,
    }
  }

  if !empty($mysql_db){

    mysql::db { $mysql_db:
      user     => $mysql_user,
      password => $mysql_password,
      host     => $mysql_host,
      grant    => ['ALL'],
    }
  }

  apache::vhost { $real_host:
    port    => '80',
    docroot => $real_docroot,
    # directories => [ { path => $real_docroot, options => ['Indexes','FollowSymLinks'] }],
    docroot_owner => $name,
    docroot_group => $name,
    serveraliases => "www.${real_host}", 
    override => "All",
    require => [
      Group["Add ${name} group"],
      User["Add ${name} user"],
      File["pool-${name}"],
    ],
    custom_fragment => "
      <IfModule mod_fastcgi.c>
        AddHandler php5-fcgi .php
        Action php5-fcgi /php5-fcgi
        Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi-${name}
        FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi-${name} -socket /var/run/php5-fpm-${name}.sock -pass-header Authorization -idle-timeout 3600
      </IfModule>
    ",
  }
}