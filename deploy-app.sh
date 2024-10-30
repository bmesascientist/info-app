#!/bin/bash

# export K3S_KUBECONFIG_MODE="644"

export K3S_KUBECONFIG_MODE="666"

curl -sfL https://get.k3s.io | sh -

sudo snap install helm --classic

echo "Waiting for K3S..."
while [[ $(kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded | wc -l) -ne 0 ]]; do
  echo "Not yet started..."
  sleep 20
done
echo "K3S up and running!"

kubectl apply -f namespace.yaml

kubectl apply -f deployment.yaml

kubectl apply -f traefik.yaml

kubectl apply -f network-policy.yaml

lines_to_add="127.0.0.1 app.localhost
127.0.0.1 customer-1.localhost
127.0.0.1 customer-2.localhost"

sudo vim -c "normal ggO${lines_to_add}" -c "wq" /etc/hosts

echo "Hosts file updated."
