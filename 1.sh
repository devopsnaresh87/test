BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

gcloud config set compute/zone $ZONE

gcloud container clusters create io

gsutil -m cp -r gs://spls/gsp021/* .

cd orchestrate-with-kubernetes/kubernetes

kubectl create deployment nginx --image=nginx:1.10.0

sleep 10

kubectl expose deployment nginx --port 80 --type LoadBalancer

sleep 20

kubectl get services

cd ~/orchestrate-with-kubernetes/kubernetes

kubectl apply -f pods/monolith.yaml

kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf
kubectl apply -f pods/secure-monolith.yaml

kubectl apply -f services/monolith.yaml

gcloud compute firewall-rules create allow-monolith-nodeport \
  --allow=tcp:31000

kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels

kubectl apply -f deployments/auth.yaml

kubectl apply -f services/auth.yaml

kubectl apply -f deployments/hello.yaml

kubectl apply -f services/hello.yaml

kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl apply -f deployments/frontend.yaml
kubectl apply -f services/frontend.yaml

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
