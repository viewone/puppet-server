define server_user ($uid, $gid, $key, $key_name, $password, $shell) {

    group { $name :
        name   => $name,
        ensure => 'present',
        gid    => $gid,
    }

    user { $name :
        name => $name,
        ensure => 'present',
        managehome => true,
        password => $password,
        gid => $gid,
        uid => $uid,
        shell => $shell,
    }

    if !empty($key) {

        ssh_authorized_key { $name :
            ensure => present,
            key    => $key,
            type   => 'ssh-rsa',
            name   => $key_name,
            user   => $name,
            require => User[$name],
        }
    }
}
