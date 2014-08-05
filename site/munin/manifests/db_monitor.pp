class munin::db_monitor (
  $user = "munin",
  $password = undef,
  $hostname = "localhost",
) {

  require mysql::server
  require munin

  # Create a monitoring user for Munin.
  mysql_user { "${user}@${hostname}":
    ensure        => present,
    password_hash => mysql_password($password),
    require       => Class['mysql::server::service'],
  }

  mysql_grant { "${user}@${hostname}/*.*":
    ensure     => present,
    user       => "${user}@${hostname}",
    table      => '*.*',
    privileges => [ 'PROCESS', 'REPLICATION CLIENT' ],
    require    => Mysql_user["${user}@${hostname}"],
  }

  mysql_grant { "${user}@${hostname}/mysql.*":
    ensure     => present,
    user       => "${user}@${hostname}",
    table      => 'mysql.*',
    privileges => [ 'SELECT' ],
    require    => Mysql_user["${user}@${hostname}"],
  }

  # Configure MySQL munin plugin.
  file { "/etc/munin/plugin-conf.d/mysql":
    owner => root,
    group => root,
    mode => 0600,
    content => template('munin/etc/munin/plugin-conf.d/mysql.erb'),
  }

}
