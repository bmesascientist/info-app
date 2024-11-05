#!/bin/bash

NAMESPACE="kube-system"
PORT=9000

POD_NAME=$(k3s kubectl get pod -n $NAMESPACE --no-headers -o custom-columns=":metadata.name" | grep '^traefik-')

if [ -z "$POD_NAME" ]; then
  echo "Traefik pod can't find. Please check K3S installed correctly."
  exit 1
else
  echo "Traefik pod found: $POD_NAME"
fi

NODE_IP=$(k3s kubectl get nodes -o wide --no-headers -o custom-columns=":status.addresses[0].address")

echo "Port forwarding to: $NODE_IP:$PORT -> $POD_NAME:$PORT"

nohup k3s kubectl port-forward $POD_NAME -n $NAMESPACE $PORT:$PORT --address 0.0.0.0 >/dev/null 2>&1 &

echo "You can access Traefik Dashboard via: http://$NODE_IP:$PORT/dashboard/#/"
