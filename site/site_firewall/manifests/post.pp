class site_firewall::post {

  # This class ensures any default firewall rules are applied last.

  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }

}
