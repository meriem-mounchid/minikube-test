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

_______________________________________________________________________________


helm install --namespace test --generate-name --set volumePermissions.enabled=true -f values.yaml bitnami/postgresql

helm install --namespace postgresql-dev postgresql-dev --set volumePermissions.enabled=true -f values.yaml bitnami/postgresql
helm install --namespace postgres postgresql-dev --set volumePermissions.enabled=true -f values.yaml bitnami/postgresql
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
psql --host postgresql-dev -U app1 -d app_db -p 5432

postgres -D /usr/local/var/postgres

psql -h /tmp/ postgres

  # postgresPassword: "StrongPassword"
  # username: "app1"
  # password: "AppPassword"
  # database: "app_db"
CREATE TABLE COMPANY(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);
CREATE TABLE DEPARTMENT(
   ID INT PRIMARY KEY      NOT NULL,
   DEPT           CHAR(50) NOT NULL,
   EMP_ID         INT      NOT NULL
);
CREATE TABLE TEST(
   ID INT PRIMARY KEY      NOT NULL,
   DEPT           CHAR(50) NOT NULL,
   EMP_ID         INT      NOT NULL
);


kubectl exec -it postgresql-dev-0 -- psql -h postgresql-dev-0 -U app1 --password -p 5432 app_db

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

kubectl create namespace postgres

vim postgres-configmap.yaml
# Create ConfigMap postgres-secret for the postgres app
# Define default database name, user, and password
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-secret
  labels:
    app: postgres
data:
  POSTGRES_DB: appdb
  POSTGRES_USER: appuser
  POSTGRES_PASSWORD: strongpasswordapp

# kubectl apply -f postgres-configmap.yaml -n postgres

vim postgres-volume.yaml
apiVersion: v1
kind: PersistentVolume # Create PV 
metadata:
  name: postgres-volume # Sets PV name
  labels:
    type: local # Sets PV's type
    app: postgres
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi # Sets PV's size
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/data/postgresql" # Sets PV's host path
  
# kubectl apply -f postgres-volume.yaml -n postgres

vim postgres-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim # Create PVC
metadata:
  name: postgres-volume-claim # Sets PVC's name
  labels:
    app: postgres # Defines app to create PVC for
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi # Sets PVC's size

# kubectl apply -f postgres-pvc.yaml -n postgres

vim postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment # Create a deployment
metadata:
  name: postgres # Set the name of the deployment
spec:
  replicas: 3 # Set 3 deployment replicas
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:12.10 # Docker image
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432 # Exposing the container port 5432 for PostgreSQL client connections.
          envFrom:
            - configMapRef:
                name: postgres-secret # Using the ConfigMap postgres-secret
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: postgresdata
      volumes:
        - name: postgresdata
          persistentVolumeClaim:
            claimName: postgres-volume-claim

# kubectl apply -f postgres-deployment.yaml -n postgres

vim postgres-service.yaml
apiVersion: v1
kind: Service # Create service
metadata:
  name: postgres # Sets the service name
  labels:
    app: postgres # Defines app to create service for
spec:
  type: NodePort # Sets the service type
  ports:
    - port: 5432 # Sets the port to run the postgres application
      targetPort: 5432  
  selector:
    app: postgres

# kubectl apply -f postgres-service.yaml -n postgres

# Test:
kubectl exec -it -n postgres postgres-75b8fd84f-8v2r8 -- psql -h localhost -U appuser --password -p 5432 appdb
psql -h 192.168.59.142 -U appuser --password -p 32555 appdb
Password: strongpasswordapp

---
vim  ingress-controller.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-service
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: adminer.k8s.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:  
              service:
                name: adminer
                port:
                  number: 80

# kubectl apply -f ingress-controller.yaml -n postgres
minikube addons enable ingress
minikube tunnel
