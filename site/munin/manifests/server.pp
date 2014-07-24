class munin::server {

  package { ["munin", "munin-cgi", "munin-async"]: }

  file { "/etc/httpd/conf.d/munin-cgi.conf":
    source => "puppet:///modules/munin/etc/httpd/conf.d/munin-cgi.conf",
  }

  file { "/etc/munin/munin.conf":
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/munin/etc/munin/munin.conf",
    require => Package['munin'],
  }
}
