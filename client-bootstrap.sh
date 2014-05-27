#!/bin/sh

# client-bootstrap.sh: preps a RS CentOS VM for puppet.
# Installs puppet, hiera, and their dependencies.
# This script assumes a CentOS 6.x host.

# Install Puppet repos. Note: EPEL is installed by default on Rackspace CentOS images.
rpm -q --quiet puppetlabs-release || rpm -Uvh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Install puppet and friends.
yum -y install puppet git rubygems rubygems-deep-merge

# Configure puppet.
echo "    pluginsync = true" >> /etc/puppet/puppet.conf
echo "    server = prod-util1.cashmusic.org" >> /etc/puppet/puppet.conf
