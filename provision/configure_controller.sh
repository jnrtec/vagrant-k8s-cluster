#!/bin/bash

# Inicializar o cluster Kubernetes se for o nó mestre
if [ "$(hostname)" == "kubemaster01" ]; then
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16
  
  # Configurar kubectl para o usuário root
  mkdir -p /root/.kube
  sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
  sudo chown $(id -u):$(id -g) /root/.kube/config
  
  # Instalar a rede de pods (Flannel)
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi
