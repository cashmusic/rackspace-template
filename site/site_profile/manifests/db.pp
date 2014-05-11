class site_profile::db {
  # Class to setup database servers.

  # Firewall configuration for db hosts.
  $firewall_rules = hiera_hash('site_profile::db::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # dbclient class handles mysql->mysql55 client/libs packages.  
  require site_profile::dbclient

  $mysql_options = hiera_hash('site_profile::db::mysql_options')
  class { 'mysql::server': override_options => $mysql_options }

  # Need to run the dbclient class first before installing the server
  # due to packaging conflicts between base mysql and IUS mysql.
  Class['site_profile::dbclient'] -> Class['mysql::server']

  # Install mysql related packages.
  class { 'yumrepos::percona': }

  $mysql_additional_pkgs = hiera_array('site_profile::db::mysql_additional_pkgs', [])
  if ($mysql_additional_pkgs != []) {
    package { $mysql_additional_pkgs:
      ensure => installed,
      require => Class['yumrepos::percona'],
    }
  }

}
