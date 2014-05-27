# site_profile::base is included on all machines for standard base configuration.

class site_profile::base {

  # Firewall configuration common for all hosts.
  $firewall_rules = hiera_hash('site_profile::base::firewall_rules', {})
  create_resources('firewall', $firewall_rules)

  # Packages to be added to all machines for convenience or necessity.
  $base_packages = hiera_array('site_profile::base::base_packages', [])
  if ($base_packages != []) {
    package { $base_packages:
      ensure => installed,
    }
  }

  # System groups.
  create_resources('group', hiera_hash('system_groups', {} ))

  # User Accounts. Passwords should be stored in private hiera repo.
  create_resources('account', hiera_hash('user_accounts', {} ))

  ## Sudo configuration
  class { 'sudo': }
  sudo::conf { 'admins':
    priority => 10,
    content  => "%wheel ALL=(ALL) ALL",
  }

  ## Enable/configure sshd -- settings stored in hiera.
  class { 'ssh::server': }

  # Enable denyhosts. Default allow list is in hiera.
  class { "denyhosts": }

  # Enable yum cron. Defaults to only check for updates, not update automatically.
  if (hiera('enable_yum_cron', FALSE)) {
    class { 'yum_cron': }
  }

  # Hosts file
  $hosts = hiera_hash('site_profile::base::hosts', {})
  $equivalent_hosts = hiera_hash('site_profile::base::equivalent_hosts', [])
  file { "/etc/hosts":
    content => template('site_profile/etc/hosts.erb'),
  }

}
