GIT_PATH = "hbraux/ansible-hdp-sandbox"
BOX_RAM = "1024"  
BOX_CPU = "1" 
BOX_IP = "192.168.56.2"
BOX_FQDN = "work.hostonly.com"

Vagrant.configure("2") do |config|
	pubkey = File.readlines("key.pub").first.strip
	if Vagrant.has_plugin?("vagrant-proxyconf")
		if ENV["http_proxy"]
			config.proxy.http = ENV["http_proxy"]
			config.proxy.https = ENV["http_proxy"]
		end
	end
	config.vm.define "work" do |node|
		node.vm.box = "centos/7"
		node.vm.network :private_network, ip: BOX_IP
		node.vm.hostname = BOX_FQDN
		node.vm.synced_folder ".", "/vagrant", disabled: true
		node.vm.provider "virtualbox" do |vb|
			vb.name = "work"
			vb.customize ["modifyvm", :id, "--memory", BOX_RAM]
			vb.customize ["modifyvm", :id, "--cpus", BOX_CPU]
			vb.customize ["modifyvm", :id, "--audio", "none"]
		end
		node.vm.provision 'shell', inline: <<-END
  [[ -x /usr/bin/ansible-playbook ]] || yum --disableplugin=fastestmirror install -y curl ansible
  curl -s -O https://raw.githubusercontent.com/#{GIT_PATH}/master/install.yml
  USERNAME="#{ENV["USERNAME"]}" PUBKEY="#{pubkey}" GIT_PATH="#{GIT_PATH}" ansible-playbook install.yml
  END
	end
end

