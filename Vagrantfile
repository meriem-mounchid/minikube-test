# vagrant plugin install vagrant-vbguest
# vagrant vbguest
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "ubuntu/trusty64"
  config.vm.synced_folder ".", "/home/vagrant"
        config.vm.define "misaki" do |controle|
    controle.vm.hostname = "misaki"
    controle.vm.network "public_network", bridge: "en0: Ethernet"
    controle.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--memory", "4096"]
      v.customize ["modifyvm", :id, "--name", "misaki"]
    end
  end
end
