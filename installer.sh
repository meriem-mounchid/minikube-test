    ### ... ###

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

helm install stable/nginx-ingress
minikube addons enable ingress

# minikube update-contex

#### Deploying PostgreSQL with Helm Chart ####

# Add Helm repository by Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update Helm index charts
helm repo update
helm repo list
touch local-pv.yaml

apiVersion: v1
kind: PersistentVolume # Create a PV
metadata:
  name: postgresql-data # Sets PV's name
  labels:
    type: local # Sets PV's type to local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi # Sets PV Volume
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data/volume" # Sets the volume's path

kubectl apply -f local-pv.yaml

touch pv-claim.yaml

apiVersion: v1
kind: PersistentVolumeClaim # Create PVC
metadata:
  name: postgresql-data-claim # Sets name of PV
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce # Sets read and write access
  resources:
    requests:
      storage: 10Gi # Sets volume size

kubectl apply -f pv-claim.yaml
# Checking PersistentVolume
kubectl get pv
# Checking PersistentVolumeClaim
kubectl get pvc

touch values.yaml

# define default database user, name, and password for PostgreSQL deployment
auth:
  enablePostgresUser: true
  postgresPassword: "StrongPassword"
  username: "app1"
  password: "AppPassword"
  database: "app_db"

# The postgres helm chart deployment will be using PVC postgresql-data-claim
primary:
  persistence:
    enabled: true
    existingClaim: "postgresql-data-claim"

startupProbe:
  initialDelaySeconds: 1
  periodSeconds: 5
  timeoutSeconds: 1
  successThreshold: 1
  failureThreshold: 1

helm install postgresql-test --set volumePermissions.enabled=true -f values.yaml bitnami/postgresql
helm install postgresql-dev -f values.yaml bitnami/postgresql

# Checking pods
kubectl get pods
# Checking logs of pods
kubectl logs postgresql-dev-0

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql-dev -o jsonpath="{.data.password}" | base64 --decode)
kubectl run postgresql-dev-client --rm --tty -i --namespace default --image docker.io/bitnami/postgresql:14.1.0-debian-10-r80 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
--command -- psql --host postgresql-dev -U app1 -d app_db -p 5432

# Checking PostgreSQL connection
\conninfo
# Logout from PostgreSQL shell
exit
#10.96.208.237") at port "5432".

##### Nginx Ingress Controller ####
minikube addons enable ingress
kubectl get pods -n ingress-nginx

kubectl port-forward --namespace default svc/postgresql-dev 5432:5432

#### POSTGRESS ####
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 172.17.0.4 -U app1 -d app_db -p 5432
psql --host 10.109.168.173 -U app1 -d app_db -p 5432
psql -h localhost -U app1 -d app_db -p 5432

psql -h postgresql-dev-0 -U app1 --password -p 5432 app_db


postgres -D /usr/local/var/postgres

psql -h /tmp/ postgres

  # postgresPassword: "StrongPassword"
  # username: "app1"
  # password: "AppPassword"
  # database: "app_db"

kubectl patch svc postgresql-dev --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
kubectl exec -it postgresql-dev-0 -- psql -h postgresql-dev-0 -U app1 --password -p 5432 app_db