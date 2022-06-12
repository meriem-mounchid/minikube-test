    ### ... ###

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

helm install stable/nginx-ingress
minikube addons enable ingress

# minikube update-contex

#### Deploying PostgreSQL with Helm Chart ####

# Add Helm repository by Bitnami
helm repo add bitnami <https://charts.bitnami.com/bitnami>

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

helm install postgresql-dev --set volumePermissions.enabled=true -f values.yaml bitnami/postgresql

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


##### Nginx Ingress Controller ####
minikube addons enable ingress
kubectl get pods -n ingress-nginx

