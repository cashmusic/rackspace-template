class munin::server {

  package { ["munin", "munin-cgi", "munin-async"]: }

  file { "/etc/httpd/conf.d/munin-cgi.conf":
    source => "puppet:///modules/munin/etc/httpd/conf.d/munin-cgi.conf",
  }

  # Ensure apache is listening on port 443 for the web interface.
  apache::listen { '443': }

  file { "/etc/munin/munin.conf":
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/munin/etc/munin/munin.conf",
    require => Package['munin'],
  }
}
