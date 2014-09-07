class site_profile::mail {
  
  # Packages needed by hosts running Postfix.
  $mail_packages = hiera_array('site_profile::mail::mail_packages', [])
  if ($mail_packages != []) {
    package { $mail_packages:
      ensure => installed,
    }
  }

  # Mandrill credentials are stored in the private hiera repo.
  $postfix_sasl_passwd = hiera('site_profile::mail::sasl_passwd', 'no password set')
  postfix::dbfile {
    'sasl_passwd':
      content => template("site_profile/etc/postfix/sasl_passwd.erb");
  }

  # Alias configuration.
  $alias_entries = hiera_hash('site_profile::mail::alias_entries', { })
  file { "/etc/aliases":
    content => template("site_profile/etc/aliases.erb"),
    owner => root,
    group => root,
    mode => 644,
  }

  exec { "newaliases":
    command => "/usr/bin/newaliases",
    subscribe => File["/etc/aliases"],
    refreshonly => true,
  }

  # All postfix configuration is in hiera.
  class { 'postfix::server': }

}
