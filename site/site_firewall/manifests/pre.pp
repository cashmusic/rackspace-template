class site_firewall::pre {
  # This class ensures a base set of firewall rules.

  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    ctstate => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }

  # Following may need to be transplanted to nearer their homes, but here for now.
  firewall { '003 allow ssh access':
    port   => [22],
    proto  => tcp,
    action => accept,
  }

  # Allow web ports.
  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }

}
