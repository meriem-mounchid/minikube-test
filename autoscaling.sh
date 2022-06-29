#### AUTOSCALING #### 
kubectl get nodes
helm repo add nginx-stable https://helm.nginx.com/stable
helm install main nginx-stable/nginx-ingress --set controller.watchIngressWithoutClass=true --set controller.service.type=NodePort --set controller.service.httpPort.nodePort=30005
