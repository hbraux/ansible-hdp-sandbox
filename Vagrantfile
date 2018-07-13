BOX_NAME = "hdp"
BOX_DOMAIN = "hostonly.com"
BOX_RAM = "8192"  
BOX_CPU = "4" 
BOX_IP = "192.168.56.3"
GITHUB_REPO = "hbraux/ansible-hdp-sandbox"

Vagrant.configure("2") do |config|
	pubkey = File.readlines("key.pub").first.strip
	config.proxy.enabled = { yum: false }
	config.vm.define BOX_NAME
	config.vm.box = "centos/7"
	config.vm.network :private_network, ip: BOX_IP
	config.vm.hostname = "#{BOX_NAME}.#{BOX_DOMAIN}"
	config.vm.synced_folder ".", "/vagrant", disabled: true
	config.vm.provider "virtualbox" do |vb|
		vb.name = BOX_NAME
		vb.customize ["modifyvm", :id, "--memory", BOX_RAM]
		vb.customize ["modifyvm", :id, "--cpus", BOX_CPU]
		vb.customize ["modifyvm", :id, "--audio", "none"]
	end
	config.vm.provision 'shell', inline: "curl -s https://raw.githubusercontent.com/#{GITHUB_REPO}/master/vagrant.sh | bash -s #{GITHUB_REPO} #{ENV['USERNAME']} '#{pubkey}' #{ENV['CENTOS_MIRROR']}"
end

