node default {
  stage { 'pre': before => Stage['main'] }
  class { 'yumrepos::epel': stage => 'pre' }
  class { 'yumrepos::ius': stage => 'pre' }


  # Firewall setup
  resources { "firewall":
    purge => true
  }
  class { 'firewall': }
  Firewall {
    before  => Class['site_firewall::post'],
    require => Class['site_firewall::pre'],
  }
  class { ['site_firewall::pre', 'site_firewall::post']: }


}
