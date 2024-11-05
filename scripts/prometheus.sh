#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

helm install prometheus prometheus-community/prometheus

echo "Waiting for Prometheus..."
while [[ $(k3s kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded | wc -l) -ne 0 ]]; do
  echo "Not yet started..."
  sleep 20
done
echo "Prometheus up and running!"

k3s kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext

nohup k3s kubectl port-forward --address 0.0.0.0 service/prometheus-server-ext 9090:80 >/dev/null 2>&1 &
