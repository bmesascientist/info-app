# Info-App

Info-App is a NodeJS application for return Namespace, Pod, and Node information from a Kubernetes cluster. This application can be deployed on local K3S cluster.

## Requirements

- Ubuntu Server 24.04.1

## Table of Contents

- [Installation](#installation)

- [Deployment](#deployment)

- [Usage](#usage)

## Easy Way to Setup Server and Deploy the Application on Local

It will be setup server, deploy the application, and run the application. You can also setup Traefik Dashboard and Prometheus with this script.

```bash
. setup.sh
```

## Installation

1. **Clone the repository:**

```bash
git clone https://github.com/bmesascientist/info-app.git

cd info-app/
```

2. **Make the setup and deploy scripts executable:**

```bash
chmod u+x server-setup.sh deploy-app.sh
```

3. **Setup Docker and update the server with basic shell script:**

```bash
./server-setup.sh
```

## Deployment

1. **Deploy the application:**

```bash
./deploy-app.sh
```

### Docker

If you wanna build the Docker image, you can do it as follows:

1. **Build the Docker image:**

```bash
docker build -t info-app .
```

2. **Tag the Docker image:**

```bash
docker tag info-app your_dockerhub/info-app:latest
```

3. **Push the Docker image:**

```bash
docker push your_dockerhub/info-app:latest
```

## Usage

### Running Locally

1. **Access the application:**

```bash
curl app.localhost
```

```bash
curl customer-1.localhost
```

```bash
curl customer-2.localhost
```

#### Traefik Dashboard

1. **Get pod name:**

```bash
k3s kubectl get pod -n kube-system
```

- Example:

```bash
ubuntu@server:~$ k3s kubectl get pod -n kube-system

NAME                                      READY   STATUS      RESTARTS   AGE
coredns-7b98449c4-x9f8w                   1/1     Running     0          82s
helm-install-traefik-6l4wz                0/1     Completed   1          82s
helm-install-traefik-crd-b5mb9            0/1     Completed   0          82s
local-path-provisioner-595dcfc56f-l8gsh   1/1     Running     0          82s
metrics-server-cdcc87586-x768n            1/1     Running     0          82s
svclb-traefik-04867f53-rfqch              2/2     Running     0          45s
traefik-d7c9c5778-89dgp                   1/1     Running     0          45s
```

2. **Activate the dashboard:**

```bash
k3s kubectl port-forward pod_name -n kube-system 9000:9000 --address 0.0.0.0 &
```

- Example:

```bash
ubuntu@server:~$ sudo k3s kubectl port-forward traefik-d7c9c5778-89dgp -n kube-system 9000:9000 --address 0.0.0.0

Forwarding from 0.0.0.0:9000 -> 9000
```

2. **Get Node IP:**

```bash
k3s kubectl get nodes -o wide
```

- Example:

```bash
ubuntu@server:~$ k3s kubectl get nodes -o wide

NAME     STATUS   ROLES                  AGE   VERSION        INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
server   Ready    control-plane,master   20m   v1.30.6+k3s1   172.16.66.137   <none>        Ubuntu 24.04.1 LTS   6.8.0-48-generic   containerd://1.7.22-k3s1
```

3. **Access the dashboard outside of VM:**

```text
<node_ip>:9000/dashboard/#/
```

#### Prometheus

1. **Setup:**

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

```bash
helm repo update
```

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

```bash
helm install prometheus prometheus-community/prometheus
```

2. **Port-forward:**

```bash
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext
```

```bash
kubectl port-forward --address 0.0.0.0 service/prometheus-server-ext 9090:80
```

3. **Access the Prometheus outside of VM:**

```text
<node_ip>:9090
```

4. **Get simple metrics for CPU and Memory:**

```bash
curl "http://localhost:9090/api/v1/query?query=100%20-%20(avg%20by(instance)%20(irate(node_cpu_seconds_total%7Bmode%3D%22idle%22%7D%5B5m%5D))%20*%20100)" | jq .
curl "http://localhost:9090/api/v1/query?query=((node_memory_MemTotal_bytes%20-%20node_memory_Available_bytes)%20/%20node_memory_MemTotal_bytes)%20*%20100" | jq .
```
