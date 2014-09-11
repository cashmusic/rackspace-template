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

filebucket { main: server => puppet }

## Global Defaults
File {
  owner => 'root',
  group => 'root',
  mode => 0644,
  backup => main
}
Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin" }
# Default firewall rules to tcp protocol, and accept so they
# don't need to be defined with each rule.
Firewall { proto => tcp, action => accept }

# Default Package settings.
# Avoid warning from newer versions of Puppet.
Package {  allow_virtual => false, }

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
