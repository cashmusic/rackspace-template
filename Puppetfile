# This is currently a noop but will be supported in the future.
forge 'forge.puppetlabs.com'

# Install modules from the Forge
mod 'jeffsheltren/yumrepos', '0.3.3'
mod 'puppetlabs/apache', '1.4.1'
mod 'puppetlabs/concat', '1.0.0'
mod 'puppetlabs/firewall', '1.0.2'
mod 'puppetlabs/inifile', '1.0.3'
mod 'puppetlabs/java', '1.1.0'
mod 'puppetlabs/mysql', '3.3.0'
mod 'puppetlabs/ntp', '3.1.2'
mod 'puppetlabs/stdlib', '4.3.2'
mod 'puppetlabs/vcsrepo', '0.1.1'
mod 'rtyler/jenkins', '1.1.0'
mod 'saz/sudo', '3.0.2'
mod 'saz/ssh', '2.3.4'
mod 'stephenrjohnson/puppet', '1.3.1'
mod 'thias/postfix', '0.3.3'
mod 'treydock/yum_cron', '1.0.0'
mod 'torrancew/account', '0.0.5'

# Using a direct git reference instead of a module install
# until these latest commits are rolled into a release.
mod 'php',
  :git => 'git://github.com/thias/puppet-php.git',
  :ref => 'f83e6f0e68fa7926fa1c5eb24353e020b8f87860'

# puppetlabs denyhosts is mostly unmaintained at this point.
# This fork adds RHEL support.
mod 'denyhosts',
  :git => 'git://github.com/nnewton/puppetlabs-denyhosts.git',
  :ref => 'master'
