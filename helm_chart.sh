helm create postgresxd
cd templates
rm -rf *
---
# vim deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.postgresxd.name }}
  labels:
    app: {{ .Values.postgresxd.name }}
    group: {{ .Values.postgresxd.group }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.postgresxd.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.postgresxd.name }}
        group: {{ .Values.postgresxd.group }}
    spec:
      volumes:
        - name: {{ .Values.postgresxd.volume.name }}
          persistentVolumeClaim:
            claimName: {{ .Values.postgresxd.volume.pvc.name }}
      containers:
        - name: {{ .Values.postgresxd.name }}
          image: {{ .Values.postgresxd.container.image }}  
          ports:
            - containerPort: {{ .Values.postgresxd.container.port }}
          envFrom:
            - configMapRef:
                name: {{ .Values.postgresxd.config.name }}
          volumeMounts:             
            - name: {{ .Values.postgresxd.volume.name }}
              mountPath: {{ .Values.postgresxd.volume.mountPath }} 
---
# vim pvc.yaml
apiVersion: v1
kind: {{ .Values.postgresxd.volume.kind }}
metadata:
  name: {{ .Values.postgresxd.volume.pvc.name }}
spec:
  accessModes:
    - {{ .Values.postgresxd.volume.pvc.accessMode }}
  resources:
    requests:
      storage: {{ .Values.postgresxd.volume.pvc.storage }}
---
# vim service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.postgresxd.name }}
  labels: 
    group: {{ .Values.postgresxd.group }}
spec:
  type: {{ .Values.postgresxd.service.type }}
  selector:             
    app: {{ .Values.postgresxd.name }}
  ports:
    - port: {{ .Values.postgresxd.service.port }}       
      targetPort: {{ .Values.postgresxd.container.port }}   
---
# vim config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.postgresxd.config.name }}
  labels:
    group: {{ .Values.postgresxd.group }}
data: 
{{- range .Values.postgresxd.config.data }}
  {{ .key }}: {{ .value }}
{{- end}}
---
# vim Chart.yaml 
apiVersion: v2
name: postgresxd
description: A Helm chart for PostgreSQL database
type: application
version: 0.1.0
appVersion: 1.16.0
keywords:
  - database
  - postgresxd
home: https://github.com/wkrzywiec/k8s-helm-helmfile/tree/master/helm
maintainers:
  - name: Wojtek Krzywiec
    url: https://github.com/wkrzywiec
---
# vim values.yaml
replicaCount: 1
postgresxd:
  name: postgresxd
  group: db
  container:
    image: postgres:9.6-alpine
    port: 5432
  service:
    type: ClusterIP
    port: 5432
  volume:
    name: postgres-storage
    kind: PersistentVolumeClaim
    mountPath: /var/lib/postgresql/data
    pvc:
      name: postgres-persistent-volume-claim
      accessMode: ReadWriteOnce
      storage: 4Gi
  config:
    name: postgres-config
    data:
       - key: key
         value: value
---
# vim data-postgres.yaml
postgres:
    config:
        data:
            - key: POSTGRES_DB
              value: kanban
            - key: POSTGRES_USER
              value: kanban
            - key: POSTGRES_PASSWORD
              value: kanban
---
helm install -f data-postgres.yaml postgresxd .
# helm upgrade -i postgresxd .
---
CREATE TABLE KABAN(
   ID INT PRIMARY KEY      NOT NULL,
   DEPT           CHAR(50) NOT NULL,
   EMP_ID         INT      NOT NULL
);

kubectl exec -it -n default postgresxd-856d8977f-vf5sk -- psql -h localhost -U kanban --password -p 5432 kanban
psql -h 192.168.59.142 -U kanban --password -p 5432 kanban

# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update
# helm install ingress-nginx ingress-nginx/ingress-nginx
# helm upgrade -i ingress ./ingress
# kubectl get ValidatingWebhookConfiguration
# kubectl describe ing
# kubectl --namespace default get services -o wide -w ingress-nginx-controller
#  kubectl describe pods

________________________ TEST ________________________
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
________________________ *** ________________________

