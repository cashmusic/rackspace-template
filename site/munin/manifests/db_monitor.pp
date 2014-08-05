class munin::db_monitor (
  user => "munin",
  password => undef,
  hostname => "localhost",
) {

  require mysql::server

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

}
