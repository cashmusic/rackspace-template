class site_profile::puppetmaster (
  $puppet_all_notification_entries = [],
  $puppet_warning_notification_entries = [],
) {

  $firewall_rules = hiera_hash('site_profile::puppetmaster::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Setup: The puppet repo should be manually cloned into puppet master directory (e.g. /etc/puppetmaster)
  class { "puppet::master": }

  file { "/etc/puppet/tagmail.conf":
    content => template('site_profile/etc/puppet/tagmail.conf.erb'),
    notify => Service['httpd'],  # Since we're running under passenger, notify apache
  }

  puppet::masterenv{ 'production':
    modulepath => hiera('puppet::master::modulepath', '/etc/puppetmaster/modules')
    manifest => hiera('puppet::master::manifest', '/etc/puppetmaster/manifests/site.pp')
  }

  # Fileserver.conf is not installed/managed by puppet::master, so we hack it in.
  file { "/etc/puppet/fileserver.conf":
    source => "puppet:///modules/site_profile/etc/puppet/fileserver.conf",
    notify => Service['httpd'],
  }
}
