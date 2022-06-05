### Install ssh ###
sudo apt update
sudo apt install -y openssh-server

### Install Docker ###
sudo apt install -y docker.io
# docker --version
sudo usermod -aG docker misaki
sudo usermod -aG sudo misaki


### Install KVM on Ubuntu ###
sudo apt-get install apt-transport-https
sudo apt-get -y upgrade
sudo apt -y install qemu-kvm libvirt-dev bridge-utils virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
sudo modprobe vhost_net
sudo lsmod | grep vhost
echo "vhost_net" | sudo tee -a /etc/modules
sudo apt install -y virtualbox virtualbox-ext-pack
sudo apt install libvirt-clients

sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo adduser `id -un` libvirt
# virsh list --all
sudo apt-get install virt-manager
sudo modprobe dm-loop
### Download minikube on Ubuntu ###
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
# minikube version

### Install kubectl on Ubuntu ###
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
# kubectl config get-contexts


### Starting minikube on Ubuntu ###
minikube delete --all --purge
minikube start --driver=virtualbox --no-vtx-check

sudo chown -R $USER $HOME/.minikube
sudo apt-get install -y conntrack
minikube start --driver=none

minikube status
sudo rm -rf /tmp/minikube.*
sudo rm -rf /tmp/juju-mk*
