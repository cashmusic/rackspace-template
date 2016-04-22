# CASH Music Infrastructure

This repo contains the Puppet scripts used to configure the CASH Music infrastructure and developer VMs.

For developers, all that's needed to get it working is [Vagrant](http://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/). You can and should also install the [Vagrant Hostsupdater plugin](https://github.com/cogitatio/vagrant-hostsupdater) if you'd like Vagrant to automatically add an entry to your local hosts file and the [Vagrant vbguest plugin](https://github.com/dotless-de/vagrant-vbguest) to automatically update the VirtualBox Guest Additions within the VM. There are a few configuration steps before getting the machine going:

1. Install Vagrant, Virtualbox, and optionally the hostsupdater plugin (```vagrant plugin install vagrant-hostsupdater```) and the vbguest plugin (```vagrant plugin install vagrant-vbguest```) after installing Vagrant.
2. Clone this repo.
3. Clone the [CASH Music Platform repo](https://github.com/cashmusic/platform).
4. In the Platform codebase, copy ```framework/settings/cashmusic_template.ini.php``` to ```framework/settings/cashmusic.ini.php``` and use the following DB credentials:
```
driver = "mysql" ;* sqlite or mysql
hostname = "localhost"
username = "cash_dev_rw"
password = ""
database = "cash_dev"
```
Be sure to leave the security salt as the default: ```I was born of sun beams; Warming up our limbs``` so that the imported database works as expected.

Next, configure Vagrant for your environment:

5. Copy Vagrantfile.local.example to Vagrantfile.local
6. Edit Vagrantfile.local to point the dev mount to your local clone of the Platform repo. Optionally configure the VM CPU and memory allocations or VM IP address.
7. Optionally: edit your /etc/hosts file to add an entry for the virtual machine (or let the Hostsupdater plugin do this for you automatically).
  
You're good. Now all you need is:
  
```
vagrant up
```

The first time this is run, it will download a base box image which is around 400 MB, so expect this to take a while if you have a slow connection. Once the box is downloaded, a set of scripts will run to bootstrap the VM with needed packages, and then Puppet will run to configure the VM with PHP, MySQL and other fun stuff. This initial setup can take 5-10 minutes or more depending on your hardware and network connection. Subsequent ```vagrant up``` runs will be much faster since everything will already be setup.

When you are done using the machine, use ```vagrant halt``` to shutdown the VM and save battery life and precious CPU cycles that could be better used looking at cat and dog pictures on the Internet.

## Accessing the CASH Music Dev Instance
The Puppet provisioning scripts will load in the SQL schema from the Platform repo and load in a default user (dev@cashmusic.org / dev).

If you've added an entry to your /etc/hosts file (or had it done for you automatically with the HostsUpdater plugin), you should be able to access the site at http://vagrant-multi1.cashmusic.org.  Otherwise, you can use the IP directly (defaults to 10.10.10.20).

The MySQL database is cash_dev, and it can be accessed by the cash_dev_rw user without a password.

You can ssh to the Vagrant VM using ```vagrant ssh```.
