#
# CASH Music basic box @ Rackspace
#
require 'yaml'
$cfg = YAML::load_file('./config/config.yml')

$box = 'dummy'
$box_url = 'https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box'


Vagrant.configure("2") do |config|
  config.vm.box = $box
  config.vm.box_url = $box_url

  config.ssh.private_key_path = $cfg[:ssh_private_key_location]
  
  config.vm.provider :rackspace do |rs|
    rs.username = $cfg[:rackspace_user]
    rs.api_key = $cfg[:rackspace_key]
    rs.rackspace_region = $cfg[:rackspace_region]
    rs.flavor = $cfg[:rackspace_flavor]
    rs.image = /Ubuntu 12.04/
    rs.public_key_path = $cfg[:ssh_public_key_location]
    rs.server_name = $cfg[:rackspace_server_name]
    if $cfg[:rackspace_allow_servicenet]
      rs.network :service_net, :attached => false
    end
  end

  config.vm.synced_folder '.', '/vagrant', 
    owner: 'vagrant', 
    group: 'www-data',
    mount_options: ["dmode=777,fmode=777"]

  config.vm.provision "shell", inline: <<-shell
    #!/bin/bash
    sudo apt-get update
    sudo apt-get -y install make curl apache2 php5 libapache2-mod-php5 php5-mcrypt php5-mysql php5-sqlite php5-curl php5-suhosin unzip
    #
    # CHANGE APACHE SETTINGS AND APACHE ENVIRONMENT VARIABLES
    sudo cp -f /vagrant/.vagrant_settings/apache/default /etc/apache2/sites-available/default
    sudo cp -f /vagrant/.vagrant_settings/apache/envvars /etc/apache2/envvars
    #
    # ENABLE MOD REWRITE
    sudo a2enmod rewrite 
    #
    # RESTART APACHE
    sudo /etc/init.d/apache2 restart
    #
    * GET CASH PLATFORM STUFF
    wget https://codeload.github.com/cashmusic/platform/zip/production
    unzip production
    rm production
    mv ./platform-production/.htaccess /vagrant/.htaccess
    mv ./platform-production/interfaces /vagrant/interfaces
    mv ./platform-production/framework /vagrant/framework
    mv ./platform-production/.vagrant_settings /vagrant/.vagrant_settings
    rm -rf ./platform-production
    #
    # CASH MUSIC CHECK/INSTALL
    php /vagrant/.vagrant_settings/vagrant_cashmusic_installer.php
  shell
end
