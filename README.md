# ansible-hdp-sandbox

### Overview

An ansible playbook to build a CentOS7 / HDP 2.x sandbox with
* Ambari
* Kerberos
* PostgreSQL
* Hadoop Core (HDFS, YARN, Mapreduce)
* Hive (on Mapreduce)
* HBase
* Ranger with plugins enabled

Tested with releases
* HDP 2.6

Note that official Hortonworks ansible scripts are availabe here https://github.com/hortonworks/ansible-hortonworks


### Requirements

* OS: Windows 7 or greater
* Hardware: the VM requires at least 8GB RAM and 4 core (adjust the Vagrantfile is needed)


### Installation

Option A: create a VM for Windows 
* install [Virtualbox](https://www.virtualbox.org/)
* install [Vagrant](https://www.vagrantup.com/downloads.html)
* optionnaly install [Proxy plugin](https://github.com/tmatilai/vagrant-proxyconf) for Vagrant and set http_host in Windows
* download `Vagrantfile` from the Git repo (only that file is needed) and save it to a work directory
* create SSH keys for Putty using [Puttygen](https://www.ssh.com/ssh/putty/windows/puttygen) and save the public key as `key.pub` in the work directory
* Open a CMD prompt, go to the work and directory run `vagrant up`
* Connect with putty to 192.168.56.3 using the private key file and your Windows's username. The UNIX user created has sudo access
* Connect to http://192.168.56.3:8080/ for ambari
* Add line `192.168.56.3 hdp.hostonly.com` to your Windows host file

Option B: existing Linux environment
* install ansible 
* clone the git repo
* run ansible-playbook install.yml


