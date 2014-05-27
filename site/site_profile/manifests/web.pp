class site_profile::web {

  # Firewall configuration for web hosts.
  $firewall_rules = hiera_hash('site_profile::web::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Setup Apache base class.
  class  { 'apache': }

  # Create apache vhosts.
  create_resources('apache::vhost', hiera_hash('site_profile::web::vhosts', {}))

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
  create_resources('php::ini', hiera_hash('site_profile::web::php_ini', {}))
  class { 'php::cli': }

  # Install php-fpm and add FPM configuration.
  class { 'php::fpm::daemon': }
  # php-fpm ships with a default 'www' config, so we default to that.
  create_resources('php::fpm::conf', hiera_hash('site_profile::web::php_fpm_conf', {}))

  # Install PHP modules (extensions).
  $php_packages = hiera_array('site_profile::web::php_packages', [])
  $php_pear_packages = hiera_array('site_profile::web::php_pear_packages', [])
  php::module { $php_packages: }
  # Install PHP Pear packages.
  php::module { $php_pear_packages: }

  # APC module configuration.
  php::module::ini { 'apc':
                     pkgname => hiera('site_profile::web::php_apc_packagename', 'php54-pecl-apc'),
                     settings => hiera_hash('site_profile::web::php_apc_ini', {}),
                   }

  # Setup fastcgi configuration to point to php-fpm.
  class { 'yumrepos::repoforge': }

  package { "mod_fastcgi":
    ensure => present,
    require => Class['yumrepos::repoforge'],
  }

  # TODO: this should be in a template, configurable with hiera values.
  file { "/etc/httpd/conf.d/fastcgi.conf":
    source => "puppet:///modules/site_profile/etc/httpd/conf.d/fastcgi.conf",
    require => [ Package['mod_fastcgi'], Class['apache'] ],
    notify => Service['httpd'],
  }

  # Create apache vhosts.
  $vhosts = hiera('vhosts', {} )
  create_resources('apache::vhost', $vhosts)

}
