# site.pp

# Pull "hostenv" (a.k.a environment) and "type" out of fqdn
# to be used by Hiera.
# Hostname examples:
# prod-web1.cashmusic.org => hostenv: prod; hosttype: web
# stage-db1.cashmusic.org => hostenv: stage; hosttype: db
# dev-multi1.cashmusic.org => hostenv: stage; hosttype: multi
# vagrant-multi1.dev => hostenv: vagrant; hosttype: multi
$hostenv = regsubst($fqdn, '^([a-z]+)-([a-z]+)(\d)\.(.*)$', '\1')
$hosttype = regsubst($fqdn, '^([a-z]+)-([a-z]+)(\d)\.(.*)$', '\2')

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
