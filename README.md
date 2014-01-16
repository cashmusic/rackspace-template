Rackspace template
==================

A Vagrant environment for launching new CASH instances on Rackspace cloud servers. This lets us launch platform instances in the Rackspace cloud. Right now this is a very basic configuration — SQLite instead of MySQL and an unhardened Apache. 
  
All that's needed to get it working is [Vagrant](http://www.vagrantup.com/) [the Rackspace Vagrant plugin](http://developer.rackspace.com/blog/vagrant-now-supports-rackspace-open-cloud.html). There are a few configuration steps before getting the machine going: 
  
1. Copy config/config_template.yml to config/config.yml
2. Add your Rackspace username and API key to the config file
3. Generate a new set of SSH keys. Do this. Do it. You need to do it. Why do you hate security?
4. Put the keys in your ~/.ssh folder, then point to them in the config file
  
You're good. Now all you need is:
  
```
vagrant up --provider=rackspace
```
  

## Links 
[Rackspace Vagrant announcement/instructions](http://developer.rackspace.com/blog/vagrant-now-supports-rackspace-open-cloud.html)
[Documentation for the Rackspace Vagrant plugin](https://sourcegraph.com/github.com/mitchellh/vagrant-rackspace)
[Rackspace Performance benchmarks / server flavor names](http://developer.rackspace.com/blog/welcome-to-performance-cloud-servers-have-some-benchmarks.html)
[Rad SSH keygen guide from Github](https://help.github.com/articles/generating-ssh-keys)