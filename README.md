Rackspace template
==================

A Vagrant environment for launching new CASH instances on Rackspace cloud servers. This lets us launch platform instances in the Rackspace cloud. Right now this is a very basic configuration — SQLite instead of MySQL and an unhardened Apache.

All that's needed to get it working is [Vagrant](http://www.vagrantup.com/) and [the Rackspace Vagrant plugin](http://developer.rackspace.com/blog/vagrant-now-supports-rackspace-open-cloud.html). There are a few configuration steps before getting the machine going:

1. Copy Vagrantfile.local.example to Vagrantfile.local
2. Add your Rackspace username and API key to Vagrantfile.local
3. Generate a new set of SSH keys. Do this. Do it. You need to do it. Why do you hate security?
4. Put the keys in your ~/.ssh folder, then point to them in Vagrantfile.local
5. Optional: Edit the Rackspace settings in Vagrantfile.local to specify region, and type of VM ("rackspace_flavor"). At this point, *only* CentOS 6.x is supported.
  
You're good. Now all you need is:
  
```
vagrant up --provider=rackspace
```
  

General notes
-------------
We rely on external "Forge" modules as much as possible, and use r10k (https://github.com/adrienthebo/r10k) to pull them in from external repos as needed.

site/ and dist/ directories contain locally developed modules. The modules/ directory is automatically populated by r10k and nothing in there should be edited directly.

We push configuration information into Hiera as much as possible so that modules remain clean of specific host/group details.

## Links 
[Rackspace Vagrant announcement/instructions](http://developer.rackspace.com/blog/vagrant-now-supports-rackspace-open-cloud.html)  
[Documentation for the Rackspace Vagrant plugin](https://sourcegraph.com/github.com/mitchellh/vagrant-rackspace)  
[Rackspace Performance benchmarks / server flavor names](http://developer.rackspace.com/blog/welcome-to-performance-cloud-servers-have-some-benchmarks.html)  
[Rad SSH keygen guide from Github](https://help.github.com/articles/generating-ssh-keys)
