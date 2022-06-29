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
sudo apt -y install qemu-kvm libvirt-test bridge-utils virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
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

### Install Helm ###
brew install helm

### Starting minikube on Ubuntu ###

minikube delete --all --purge
minikube start
minikube status

# helm repo remove ..
# helm delete ..
# helm search repo bitnami


# kubectl get pods -A
helm repo add bitnami https://charts.bitnami.com/bitnami

# helm repo list

    ### TEST 00 ###
helm install postgresql-dev --set auth.postgresPassword=root bitnami/postgresql
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql-test -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD
kubectl run postgresql-dev-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:14.3.0-debian-10-r22 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host postgresql-dev -U postgres -d postgres -p 5432
# kubectl get all
# \l

    ### helm nginx ###
### Deploy nginx Ingress Controller (Yaml & Helm)
# kubectl get svc
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx


helm repo add stable https://charts.helm.sh/stable
helm create hello-world
kubectl create namespace dev 

    ### NGINX Ingress Controller via Helm ###
minikube addons enable ingress
# kubectl get pods -n ingress-nginx

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

    ### Local Testing ###
kubectl create deployment mynginx --image=httpd --port=80
kubectl expose deployment mynginx

kubectl create ingress mynginx-localhost --class=nginx \
  --rule="mynginx.localdev.me/*=mynginx:80"

kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80

    ### Online Testing ###
# kubectl get service ingress-nginx-controller --namespace=ingress-nginx
minikube tunnel
kubectl create deployment mydemo --image=httpd --port=80
kubectl expose deployment mydemo --type=LoadBalancer --port=8081 --name=my-service2
# minikube service --url DEMO
# minikube tunnel --cleanup
# kubectl delete services NAME 
# kubectl get deployments
## minikube start --extra-config=apiserver.service-node-port-range=1-65535
# kubectl delete deploy


kubectl create deployment postgresql-dev --image=postgresql-dev-0
kubectl expose deployment postgresql-dev --type=NodePort --port=8080
minikube service web --url


#### ADD ADMINER ####
helm repo add mogaal https://mogaal.github.io/helm-charts/
kubectl create namespace adminer
helm install --namespace postgres adminer-dev mogaal/adminer

helm install adminer-test mogaal/adminer

export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services adminer-dev)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
# cat /etc/hosts 


kubectl run postgresql-dev --image=bitnami/postgresql  --port=80
kubectl create deployment postgresql-dev --image=service/postgresql-dev
kubectl expose deployment postgresql-dev --type=NodePort --port=8080
# kubectl describe ingress ..

#### Create NS + Install PgAdmine ####

kubectl create ns postgres
kubectl apply -f pgadmine.yaml

kubectl patch -n adminer svc adminer-dev --type='json' -p '[{"op":"replace","path":"/spec/type","value":"ClusterIP"}]'
kubectl patch -n postgres svc postgres --type='json' -p '[{"op":"replace","path":"/spec/type","value":"ClusterIP"}]'

# helm chart pstest
# helm chart           