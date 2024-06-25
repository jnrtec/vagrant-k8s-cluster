#!/bin/bash

# Atualizar a lista de pacotes
sudo apt-get update -y

# Instalar dependências básicas
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Configurar parâmetros de sistema
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Instalar o containerd
sudo apt-get update -y
sudo apt-get install -y containerd

# Configurar o containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
