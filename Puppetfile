# This is currently a noop but will be supported in the future.
forge 'forge.puppetlabs.com'

# Install modules from the Forge
mod 'jeffsheltren/yumrepos', '0.3.3'
mod 'puppetlabs/apache', '1.0.1'
mod 'puppetlabs/concat', '1.0.0'
mod 'puppetlabs/firewall', '1.0.2'
mod 'puppetlabs/mysql', '2.2.3'
mod 'puppetlabs/stdlib', '4.1.0'
mod 'puppetlabs/vcsrepo', '0.1.1'
mod 'saz/sudo', '3.0.2'
mod 'saz/ssh', '2.3.4'
mod 'treydock/yum_cron', '1.0.0'
mod 'torrancew/account', '0.0.5'

# This php module is forked from thias/php in the forge in order
# to add parameters to the classes. We're using this fork until
# we can get our changes merged in upstream.
mod 'php',
  :git => 'git://github.com/jeffsheltren/puppet-php.git',
  :ref => '0.3.9.3-params'

# puppetlabs denyhosts is mostly unmaintained at this point.
# This fork adds RHEL support.
mod 'denyhosts',
  :git => 'git://github.com/nnewton/puppetlabs-denyhosts.git',
  :ref => 'master'
