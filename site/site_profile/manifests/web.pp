class site_profile::web {

  # Firewall configuration for web hosts.
  $firewall_rules = hiera_hash('site_profile::web::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Setup Apache base class.
  class  { 'apache': }

  # Create apache vhosts.
  create_resources('apache::vhost', hiera_hash('site_profile::web::vhosts', {}))

  # Configure logrotate for apache logs.
  file { "/etc/logrotate.d/httpd":
    source => "puppet:///modules/site_profile/etc/logrotate.d/httpd",
    require => Package['httpd'],
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

  # /server-status location is setup so that Munin can monitor apache status on web servers.
  file { "/etc/httpd/conf.d/server-status.conf":
    source => "puppet:///modules/site_profile/etc/httpd/conf.d/server-status.conf",
    require => Class['apache'],
    notify => Service['httpd'],
  }

  # Web nodes are behind a load balancer, we need mod_extract_forwarded to get the client IP,
  # and that requires mod_proxy.
  class { 'apache::mod::proxy': }

  package { 'mod_extract_forwarded':
    ensure => present,
    require => Class['apache::mod::proxy'],
  }

  # TODO: templatize this shit.
  file { "/etc/httpd/conf.d/mod_extract_forwarded.conf":
    source => "puppet:///modules/site_profile/etc/httpd/conf.d/mod_extract_forwarded.conf",
    require => [ Package['mod_extract_forwarded'], Class['apache'] ],
    notify => Service['httpd'],
  }

}
