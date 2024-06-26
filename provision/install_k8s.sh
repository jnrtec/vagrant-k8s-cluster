#!/bin/bash

# Atualiza pacotes e instalações necessárias
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Adiciona chave do repositório do Kubernetes
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Adiciona o repositório do Kubernetes
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualiza novamente após adicionar o repositório
sudo apt update

# Instala o containerd.io sem interações
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containerd.io

# Configura o containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Reinicia o containerd
sudo systemctl restart containerd

# Instala o Kubernetes
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl

# Configura o network plugin (Calico, por exemplo)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


# Configurações de rede do Kubernetes
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Inicializa o Kubernetes com kubeadm (exemplo de inicialização no nó controlador)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Copia o arquivo de configuração do Kubernetes para o usuário vagrant
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Configura o network plugin (Calico, por exemplo)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Habilita o scheduler no nó controlador (se necessário)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Instala addons (dashboard, ingress controller, etc.) se necessário

# Limpa a taint dos nós workers (se necessário)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Reinicia o kubelet para aplicar configurações
sudo systemctl restart kubelet
