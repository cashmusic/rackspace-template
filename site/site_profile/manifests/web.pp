class site_profile::web {

  # Firewall configuration for web hosts.
  $firewall_rules = hiera_hash('site_profile::web::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Setup Apache base class, includes default vhost.
  class  { 'apache': }

  # The default log rotator for httpd is not required because we use cronolog.
  file { "/etc/logrotate.d/httpd":
    ensure => absent,
    require => Package['httpd'],
  }

  # Log rotation/cleaning scripts for cronolog apache logs.
  $log_retention_days = hiera('site_profile::web::log_retention_days', 14)
  file { "/etc/cron.daily/clean-httpdlogs.sh":
    content => template('site_profile/etc/cron.daily/clean-httpdlogs.sh.erb'),
    mode => 0755,
  }
  file { "/etc/cron.daily/compress-httpdlogs.sh":
    source => "puppet:///modules/site_profile/etc/cron.daily/compress-httpdlogs.sh",
    mode => 0755,
  }

  # PHP
  # Pull in variables from Hiera.
  $php_package_basename = hiera('site_profile::web::php_package_basename', 'php53u')
  $php_packages = hiera_array('site_profile::web::php_packages', [])
  $php_pear_basename = hiera('site_profile::web::php_pear_basename', 'php-pear')
  $php_pear_packages = hiera_array('site_profile::web::php_pear_packages', [])
  $php_ini_path = hiera('site_profile::web::php_ini_path', '/etc/php.ini')

  # Setup php.ini.
  $php_ini = hiera_hash('site_profile::web::php_ini')
  if ($php_ini != nil) {
    create_resources('php::ini', $php_ini)
  }

  class { 'php::cli': cli_package_name => "${php_package_basename}-cli" }
  class { 'php::mod_php5':
          php_package_name => $php_package_basename,
          manage_httpd_php_conf => 'false',
        }
  # Install PHP modules (extensions).
  php::module { $php_packages: package_prefix => $php_package_basename }
  # Install PHP Pear packages.
  php::module { $php_pear_packages: package_prefix => $php_pear_basename }

  # APC module configuration.
  php::module::ini { 'apc':
                     pkgname => "${php_package_basename}-pecl-apc",
                     settings => hiera_hash('site_profile::web::php_apc_ini'),
                   }

  # Create apache vhosts.
  $vhosts = hiera('vhosts', {} )
  create_resources('apache::vhost', $vhosts)

}
