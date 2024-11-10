#!/bin/bash

# export K3S_KUBECONFIG_MODE="644"

export K3S_KUBECONFIG_MODE="666"

curl -sfL https://get.k3s.io | sh -

sudo snap install helm --classic

echo "Waiting for K3S..."
while [[ $(k3s kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded | wc -l) -ne 0 ]]; do
  echo "Not yet started..."
  sleep 20
done
echo "K3S up and running!"

k3s kubectl apply -f k8s-deployment/namespace.yaml

k3s kubectl apply -f k8s-deployment/deployment.yaml

k3s kubectl apply -f k8s-deployment/service.yaml

k3s kubectl apply -f k8s-deployment/hpa.yaml

k3s kubectl apply -f k8s-deployment/traefik.yaml

k3s kubectl apply -f k8s-deployment/network-policy.yaml

lines_to_add="127.0.0.1 app.localhost
127.0.0.1 customer-1.localhost
127.0.0.1 customer-2.localhost"

sudo vim -c "normal ggO${lines_to_add}" -c "wq" /etc/hosts

echo "Hosts file updated."
