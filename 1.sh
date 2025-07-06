

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

gcloud container clusters create io --zone $ZONE

gsutil -m cp -r gs://spls/gsp021/* .

cd orchestrate-with-kubernetes/kubernetes

kubectl create deployment nginx --image=nginx:1.10.0

kubectl expose deployment nginx --port 80 --type LoadBalancer

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

kubectl get services frontend
