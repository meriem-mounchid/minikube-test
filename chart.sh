export HELM_LIST=$(helm ls --all --short)
echo $HELM_LIST

minikube addons metrics-scraper
minikube addons enable dashboard
minikube addons enable metrics-server
minikube dashboard