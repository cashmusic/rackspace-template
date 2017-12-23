class site_profile::web {

  # Firewall configuration for web hosts.
  $firewall_rules = hiera_hash('site_profile::web::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Setup Apache base class.
  class  { 'apache': }

  # Create apache vhosts.
  $vhosts = hiera_hash('site_profile::web::vhosts', {})
  create_resources('apache::vhost', $vhosts)

  # Enable mod_headers.
  class { 'apache::mod::headers': }

  # Disable Proxy header (https://httpoxy.org/  https://www.apache.org/security/asf-httpoxy-response.txt)
  apache::custom_config { 'httpoxy.conf':
    content => 'RequestHeader unset Proxy early'
  }

  # Copy out SSL keys/certs if any are defined for a vhost.
  $vhost_names = keys($vhosts)
  site_profile::web::ssl_vhost_setup { $vhost_names: vhosts => $vhosts }

  # Web-related directories that may not be managed by the apache::vhosts themselves.
  $web_dirs = hiera_hash('site_profile::web::web_dirs', {})
  if ($web_dirs != {}) {
    create_resources('file', $web_dirs, {'ensure' => directory,})
  }

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

  # Be sure Apache is installed before FPM because we need the 'apache' user.
  Class['apache'] -> Class['php::fpm::daemon']

  # Install PHP modules (extensions).
  $php_packages = hiera('site_profile::web::php_packages', [])
  $php_pear_packages = hiera('site_profile::web::php_pear_packages', [])
  php::module { $php_packages: }
  # Install PHP Pear packages.
  php::module { $php_pear_packages: }

  # Install and configure PHP opcache (either APC or Zend Opcache).
  $opcache_pkg_name = hiera('site_profile::web::php_opcache_packagename', 'php-pecl-apc')
  php::module { $opcache_pkg_name: }
  case $opcache_pkg_name {
    /opcache/: {
      php::module::ini { 'opcache':
        pkgname  => $opcache_pkg_name,
        prefix   => hiera('site_profile::web::php_opcache_prefix', '10'),
        settings => hiera_hash('site_profile::web::php_opcache_ini', {}),
        zend     => true,
      }
    }
    default: {
      php::module::ini { 'apc':
        pkgname  => $opcache_pkg_name,
        settings => hiera_hash('site_profile::web::php_apc_ini', {}),
      }
    }
  }

  # Setup fastcgi configuration to point to php-fpm.
  # Remove old/broken repoforge repo.
  yumrepo { 'repoforge':
    ensure => absent,
  }

  # Add Tag1 repo for mod_fastcgi.
  yumrepo { 'tag1-fastcgi':
    descr    => 'tag1-fastcgi',
    baseurl  => 'https://pkg.tag1consulting.com/mod_fastcgi/el6/x86_64/',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'https://pkg.tag1consulting.com/RPM-GPG-KEY-TAG1',
  }

  package { "mod_fastcgi":
    ensure => present,
    require => Yumrepo['tag1-fastcgi'],
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

  # CASHMusic application configuration - per-instance configurations live in /etc/cashmusic/<instance>/.
  file { "/etc/cashmusic":
    ensure => directory,
    recurse => true,
    ignore => 'environment',
    source => [
                "puppet:///infra_private/etc/cashmusic",
                "puppet:///modules/site_profile/etc/cashmusic",
              ],
  }

  # Each server has a file which defines what CASHMusic environment it's serving (testing/staging/production).
  # This setting is stored in the hiera variable site_profile::web::deployment_environment.
  $cash_env = hiera('site_profile::web::deployment_environment', 'unknown')
  file { "/etc/cashmusic/environment":
    content => template("site_profile/etc/cashmusic/environment.erb"),
  }

  # Copy out deploy user's ssh key from the private infra repo.
  file { "/home/deploy/.ssh/id_rsa":
    owner => deploy,
    group => deploy,
    mode => 0600,
    source => [
                "puppet:///infra_private/home/deploy/dot_ssh/id_rsa",
                "puppet:///modules/site_profile/home/deploy/dot_ssh/id_rsa",
              ],
    require => User['deploy'],
  }

  # Deploy user ssh config -- avoid errors for unknown host keys.
  file { "/home/deploy/.ssh/config":
    content => '# Managed by puppet
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
',
    mode => 0600,
    owner => deploy,
    group => deploy,
    require => User['deploy'],
  }

  # Web deployment scripts.
  $web_deploy_scripts = hiera_array('site_profile::web::web_deploy_scripts', [])
  if ($web_deploy_scripts != []) {
    site_profile::web::deployscript{$web_deploy_scripts:}
  }

  # API keys.
  $api_keys = hiera_hash('site_profile::web::cash_api_keys', {})
  $key_file_defaults = {
    ensure => present,
    mode   => 0600,
    owner  => 'apache',
    group  => 'apache',
  }
  create_resources('file', $api_keys, $key_file_defaults)

  # Include sudo configuration from hiera.
  $web_sudo_conf = hiera_hash('site_profile::web::sudo_conf', {})
  create_resources('sudo::conf', $web_sudo_conf)

} # End class site_profile::web.

####################
# Web-related defined resource types.
####################

define site_profile::web::deployscript($script = $title) {
  file {"/usr/local/bin/${script}":
    ensure => file,
    source => [
                "puppet:///infra_private/usr/local/bin/${script}",
                "puppet:///modules/site_profile/usr/local/bin/${script}",
              ],
    mode => 0755,
  }
}

define site_profile::web::ssl_vhost_setup($vhosts) {
  $vhost_settings = $vhosts[$title]
  site_profile::web::ssl_cert_copy { $title:
    ssl_cert => $vhost_settings['ssl_cert'],
    ssl_key => $vhost_settings['ssl_key'],
    ssl_ca => $vhost_settings['ssl_ca'],
  }
}

define site_profile::web::ssl_cert_copy(
  $ssl_cert = undef,
  $ssl_key  = undef,
  $ssl_ca   = undef,
) {
  # Copy out ssl key, cert, ca file for vhosts where defined in a vhost definition.
  # But only if those files haven't been defined elsewhere in Puppet,
  # or potentially a shared cert for multiple vhosts.
  # Look in the private files location first, then look within the calling module.
  if (!empty($ssl_cert) and !defined(File[$ssl_cert])) {
    file { $ssl_cert:
      source => [
                  "puppet:///infra_private${ssl_cert}",
                  "puppet:///modules/site_profile${ssl_cert}",
                ],
      notify => Service['httpd'],
    }
  }
  if (!empty($ssl_ca) and !defined(File[$ssl_ca])) {
    file { $ssl_ca:
      source => [
                  "puppet:///infra_private${ssl_ca}",
                  "puppet:///modules/site_profile${ssl_ca}",
                ],
      notify => Service['httpd'],
    }
  }
  if (!empty($ssl_key) and !defined(File[$ssl_key])) {
    file { $ssl_key:
      source => [
                  "puppet:///infra_private${ssl_key}",
                  "puppet:///modules/site_profile${ssl_key}",
                ],
      mode   => 0600,
      notify => Service['httpd'],
    }
  }
}
