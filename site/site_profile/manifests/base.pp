# Stuff that should be added on every box.

class site_profile::base {

  # Packages to be added to all machines for convenience or necessity.
  $base_packages = hiera_array('site_profile::base::base_packages', [])
  if ($base_packages != []) {
    package { $base_packages:
      ensure => installed,
    }
  }

  # System groups.
  $system_groups = hiera_hash('system_groups', {} )
  if ($system_groups != {} ) {
    create_resources('group', $system_groups)
  }

  # User Accounts. Passwords should be stored in private hiera repo.
  $user_accounts = hiera_hash('user_accounts', {} )
  if ($user_accounts != {} ) {
    create_resources('account', $user_accounts)
  }

  ## Sudo configuration
  class { 'sudo': }
  sudo::conf { 'admins':
    priority => 10,
    content  => "%wheel ALL=(ALL) NOPASSWD: ALL",
  }

  ## sshd configuration
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'ClientAliveInterval' => '120',
    },
  }

  # Denyhosts.
  class { "denyhosts":
    allow => hiera("site_profile::base::allowhosts"),
  }

  # Enable yum cron. Defaults to only check for updates, not update automatically.
  if (hiera('enable_yum_cron', FALSE)) {
    class { 'yum_cron': }
  }

}
