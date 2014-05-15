class site_profile::jenkins {

  class { "::jenkins": configure_firewall => false }

  $firewall_rules = hiera_hash('site_profile::jenkins::firewall_rules', {})
  create_resources('firewall', $firewall_rules)


  file { "/var/lib/jenkins/.ssh":
    ensure => directory,
    mode => 0700,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins'],
  }

  # SSH private key - real file is in private repo,
  # default is just a placeholder for hosts outside the main infrastructure.
  file { "/var/lib/jenkins/.ssh/id_rsa":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/id_rsa",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/id_rsa",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # ssh pub key -- doesn't really need to be in the private repo, but it's nice
  # to keep them together.
  file { "/var/lib/jenkins/.ssh/id_rsa.pub":
    ensure => file,
    source => [
                "puppet:///infra_private/var/lib/jenkins/dot_ssh/id_rsa.pub",
                "puppet:///modules/site_profile/var/lib/jenkins/dot_ssh/id_rsa.pub",
              ],
    mode => 0600,
    owner => 'jenkins',
    group => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # Create directories that are be used by jenkins scripts.
  $jenkins_work_dirs = hiera_hash('site_profile::jenkins::work_directories', {})
  if ($jenkins_work_dirs != {}) {
    create_resources('file', $jenkins_work_dirs, {'ensure' => directory,})
  }

}
