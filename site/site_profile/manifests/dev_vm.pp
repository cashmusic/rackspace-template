# dev_vm: Setup cash database on a dev VM (vagrant).

class site_profile::dev_vm (
  $db_name         = 'cash_dev',
  $db_user         = 'cash_dev_rw',
  $db_pass         = undef,
  $db_host         = 'localhost',
  $dev_db_user_sql = '/root/cash_db_user.sql',
) {

  # This should run after the DB class.
  require site_profile::db

  # Create a database, use the cashmusic SQL file, which we assume is present
  # from a Vagrant mount.
  mysql::db { $db_name:
    user     => $db_user,
    password => $db_pass,
    host     => $db_host,
    grant    => ['ALL'],
    sql      => '/var/www/cash_platform/framework/settings/sql/cashmusic_db.sql',
  } ->

  exec { "load user into cash db":
    command     => "mysql $db_name < $dev_db_user_sql",
    refreshonly => true,
    subscribe => File[$dev_db_user_sql],
  }

  file { $dev_db_user_sql:
    source  => "puppet:///modules/site_profile${dev_db_user_sql}",
    replace => false,
    owner   => root,
    group   => root,
    mode    => 0644,
  }
}
