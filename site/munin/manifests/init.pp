class munin {

  package { ["munin-node", "perl-XML-SAX", "perl-Crypt-SSLeay", "perl-libwww-perl"]:  }

  service { "munin-node":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => [ Package['munin-node'], File['/etc/munin/munin-node.conf'], ]
  }

  $firewall_rules = hiera_hash('munin::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Add plugins to the main directory that we are providing
  file { "/usr/share/munin/plugins":
    source => "puppet:///modules/munin/usr/share/munin/plugins",
    mode => 0755,
    recurse => true,
    purge => false,
    require => Package['munin-node'],
  }

  file { '/usr/lib64/perl5/Munin':
    ensure => directory,
    recurse => true,
    purge => false,
    source => "puppet:///modules/munin/usr/lib64/perl5/Munin",
  }

  file { "/etc/munin/plugin-conf.d":
    source => [
      "puppet:///modules/munin/etc/munin/plugin-conf.d",
    ],
    recurse => true,
    purge => true,
    require => Package['munin-node'],
  }

# Remove all unmanaged links; we'll the the ones in we need
  file { "/etc/munin/plugins":
    ensure => directory,
    recurse => true,
    purge => true,
    require => Package['munin-node'],
  }

  # Adminscripts required for php_apc, only on webserver hosts.
  file {"/etc/munin/adminscripts":
    source => "puppet:///modules/munin/etc/munin/adminscripts",
    ensure => directory,
    recurse => true,
    purge => true,
    require => Package['munin-node'],
  }

  # Get network interface links based on fact $interfaces except loopback
  $interface_array = difference(split($interfaces, ','), ['lo'])
  munin::interface_plugin_link{$interface_array:}

  $plugins = hiera_array('munin::plugins', [])
  munin::plugin_link{$plugins:}


  file { "/etc/munin/munin-node.conf":
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/munin/etc/munin/munin-node.conf",
    require => Package['munin-node'],
    notify => Service["munin-node"],
  }

}


# Hiera entries can be either a simple array member or a hash
# For example:
#   - mysql
#   Will create a simple link plugins/mysql => /usr/share/munin/plugins/mysql
#   or
#   - php_apc_files: php_apc_
#   Will create a link plugins/php_apc_files => /usr/share/munin/plugins/php_apc_
define munin::plugin_link($plugin = $title) {
  if (is_hash($plugin)) {
    $keys = keys($plugin)
    $source = $keys[0]
    $target = $plugin[$source]
  }
  else {
    $target = $plugin
    $source = $plugin
  }
  file {"/etc/munin/plugins/${source}":
    ensure => link,
    target => "/usr/share/munin/plugins/${target}",
    force => true,
    notify => Service['munin-node'],
  }
}

define munin::interface_plugin_link($interface = $title) {
  file {"/etc/munin/plugins/if_${interface}":
    ensure => link,
    target => "/usr/share/munin/plugins/if_",
    force => true,
    notify => Service['munin-node'],
    require => Package['munin-node'],
  }
  file {"/etc/munin/plugins/if_err_${interface}":
    ensure => link,
    target => "/usr/share/munin/plugins/if_err_",
    force => true,
    notify => Service['munin-node'],
    require => Package['munin-node'],
  }

}
