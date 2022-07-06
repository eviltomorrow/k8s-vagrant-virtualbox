ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
  config.vm.provision :shell, privileged: true, path: "setup-base.sh"
  config.vm.define :master do |master|
    master.vm.provider :virtualbox do |vb|
      vb.name = "master"
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--macaddress1", "080027df86a3"]
    end

    master.vm.box = "centos/8"
    master.disksize.size = "25GB"
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: "192.168.33.10"
  end


  %w{node01 node02}.each_with_index do |name, i|
    config.vm.define name do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "node0#{i + 1}"
        vb.memory = 2048
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--macaddress1", "080027df86a#{i + 4}"]
      end
      node.vm.box = "centos/8"
      node.disksize.size = "25GB"
      node.vm.hostname = name
      node.vm.network :private_network, ip: "192.168.33.#{i + 11}"
    end
  end
end
