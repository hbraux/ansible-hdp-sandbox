BOX_NAME = "hdp"
BOX_DOMAIN = "hostonly.com"
BOX_RAM = "8192"
BOX_CPU = "4" 
BOX_IP = "192.168.56.3"
BOX_NOSYNC = true
GITHUB_REPO = "hbraux/ansible-hdp-sandbox"
SETUP_OPTS=""
password = "password"

Vagrant.configure("2") do |config|
        if File.file?("key.pub")
       	  password = File.readlines("key.pub").first.strip
	end
	config.proxy.enabled = { yum: false }
	config.vm.define BOX_NAME
	config.vm.box = "centos/7"
	config.vm.network :private_network, ip: BOX_IP
	config.vm.hostname = "#{BOX_NAME}.#{BOX_DOMAIN}"
	config.vm.synced_folder ".", "/vagrant", disabled: BOX_NOSYNC
	config.vm.provider "virtualbox" do |vb|
		vb.name = BOX_NAME
		vb.customize ["modifyvm", :id, "--memory", BOX_RAM]
		vb.customize ["modifyvm", :id, "--cpus", BOX_CPU]
		vb.customize ["modifyvm", :id, "--audio", "none"]
	end
	config.vm.provision 'shell', inline: "curl -s https://raw.githubusercontent.com/#{GITHUB_REPO}/master/vagrant.sh | bash -s #{GITHUB_REPO} #{ENV['USERNAME']} '#{password}' #{ENV['CENTOS_MIRROR']} #{SETUP_OPTS}"
end


