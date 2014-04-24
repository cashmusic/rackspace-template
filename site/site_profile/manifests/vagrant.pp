class site_profile::vagrant {

  ## vagrant additions to sudoers - otherwise vagrant can't do anything.
  sudo::conf { 'vagrant':
    content => 'vagrant ALL=(ALL) NOPASSWD: ALL',
  }
  sudo::conf { 'vagrant notty':
    content => 'Defaults:vagrant !requiretty',
  }


}
