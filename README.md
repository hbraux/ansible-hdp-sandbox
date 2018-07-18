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
* install [Proxy plugin](https://github.com/tmatilai/vagrant-proxyconf): `vagrant plugin install vagrant-proxyconf`
* optionnaly set environment variables VAGRANT_HTTP_PROXY, VAGRANT_HTTPS_PROXY and VAGRANT_NO_PROXY in Windows. If you have a prefered CentOS mirror set also the environment variable CENTOS_MIRROR to the mirror's fqdn
* download `Vagrantfile` from the Git repo and save it to a work directory. Adapt the parameters if needed
* optionnaly place RPM files in the work directory for automatic installation and update BOX_NOSYNC to false
* Open a CMD prompt, go to the work directory, run `vagrant up` and wait for VM to be ready
* Add line `192.168.56.3 hdp.hostonly.com` to your Windows host file (adapt IP if needed)
* Connect with putty to the guest VM using your Windows's username and the defaut password in Vagrantfile.
* Connect to http://hdp.hostonly.com:8080/ for ambari

In case of errors, connect to the guest VM and try running setup.sh from the git subfolder

Option B: existing Linux environment
* install ansible 
* clone the git repo
* run setup.sh



