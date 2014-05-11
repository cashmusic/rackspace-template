# site.pp

hiera_include('classes')
import "nodes/*.pp"

filebucket { main: server => puppet }

# global defaults
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin" }

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
