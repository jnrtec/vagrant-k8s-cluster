#!/bin/bash

# Atualizar a lista de pacotes
sudo apt-get update -y

# Instalar dependências básicas
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

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

# Adiciona chave do repositório do Kubernetes
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Adiciona o repositório do Kubernetes
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualiza novamente após adicionar o repositório
sudo apt-get update

# Instala o Kubernetes
sudo apt-get install -y kubelet kubeadm kubectl

# Configurações de rede do Kubernetes
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Inicializa o Kubernetes com kubeadm (exemplo de inicialização no nó controlador)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Configura o network plugin (Calico, por exemplo)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Habilita o scheduler no nó controlador (se necessário)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Limpa a taint dos nós workers (se necessário)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Reinicia o kubelet para aplicar configurações
sudo systemctl start kubelet
sudo systemctl restart kubelet


# Copia o arquivo de configuração do Kubernetes para o usuário vagrant
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verificar se a configuração foi copiada corretamente
if [ ! -f "$HOME/.kube/config" ]; then
  echo "Erro: O arquivo de configuração do Kubernetes não foi copiado corretamente."
  exit 1
fi
